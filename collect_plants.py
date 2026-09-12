#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Plant Image Collector v2
Собирает фотографии растений с iNaturalist и GBIF, раскладывает по семействам
и видам, ресайзит, чистит дубли и делает train/val/test сплит.

- Все пути считаются от расположения самого скрипта.
- Список видов лежит в species.txt рядом со скриптом. Дополняйте и запускайте снова.
- Установка зависимостей:
      pip install requests Pillow ImageHash
"""

from __future__ import annotations

import argparse
import hashlib
import logging
import os
import re
import shutil
import sys
import time
from pathlib import Path

import requests

# ---------- опциональные зависимости ----------
try:
    from PIL import Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

try:
    import imagehash
    HAS_IMAGEHASH = True
except ImportError:
    HAS_IMAGEHASH = False


# ============================================================
#                         НАСТРОЙКИ
# ============================================================
SCRIPT_DIR = Path(__file__).resolve().parent
SPECIES_FILE = SCRIPT_DIR / "species.txt"
DATASET_DIR = SCRIPT_DIR / "plant_dataset"
RAW_DIR = DATASET_DIR / "raw"
PROCESSED_DIR = DATASET_DIR / "processed"
SPLIT_DIR = DATASET_DIR / "split"
LOG_FILE = DATASET_DIR / "collector.log"

TARGET_PER_SPECIES = 300          # сколько фото нужно на вид
IMAGE_SIZE = 512          # итоговый размер (thumbnail)
JPEG_QUALITY = 92
SPLIT_RATIOS = (0.8, 0.1, 0.1)   # train / val / test
PHASH_DISTANCE = 5            # порог одинаковости (0=идеально, 5..8 — похожие)
DOWNLOAD_SLEEP = 0.03         # пауза между файлами

INAT_API = "https://api.inaturalist.org/v1"
GBIF_API = "https://api.gbif.org/v1"
HEADERS = {"User-Agent": "PlantImageCollector/2.0 (educational dataset)"}

# ------------------------------------------------------------
#                    ЛОГИРОВАНИЕ
# ------------------------------------------------------------


def setup_logging():
    DATASET_DIR.mkdir(parents=True, exist_ok=True)
    fmt = "%(asctime)s [%(levelname)s] %(message)s"
    datefmt = "%H:%M:%S"
    logging.basicConfig(
        level=logging.INFO, format=fmt, datefmt=datefmt,
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler(LOG_FILE, encoding="utf-8"),
        ],
    )


logger = logging.getLogger("collector")


# ============================================================
#                       УТИЛИТЫ
# ============================================================
IMG_EXTS = {".jpg", ".jpeg", ".png", ".webp"}


def safe_name(s: str) -> str:
    """Имя файла/папки, безопасное для всех ОС."""
    s = re.sub(r"[^\w\-. ]+", "_", s, flags=re.UNICODE)
    s = re.sub(r"\s+", "_", s).strip("._")
    return s or "Unknown"


def is_allowed_license(lic: str | None) -> bool:
    """Разрешаем только Creative Commons / public domain."""
    if not lic:
        return False
    l = lic.strip().lower()
    if "creativecommons" in l or "creative-commons" in l:
        return True
    if l in {"cc0", "cc-0", "pdm", "publicdomain", "public_domain"}:
        return True
    if l.startswith("cc-") or l.startswith("cc_"):
        return True
    return False


def iter_species_dirs(root: Path):
    """Yields папки вида <root>/<Family>/<Species> (пропускает скрытые)."""
    if not root.exists():
        return
    for fam in sorted(root.iterdir()):
        if not fam.is_dir() or fam.name.startswith("."):
            continue
        for sp in sorted(fam.iterdir()):
            if sp.is_dir() and not sp.name.startswith("."):
                yield sp


def list_images(d: Path):
    return [p for p in d.iterdir()
            if p.is_file() and p.suffix.lower() in IMG_EXTS]


# ============================================================
#                    РАЗРЕШЕНИЕ ТАКСОНА
# ============================================================
def resolve_taxon(query: str, session: requests.Session) -> dict | None:
    """
    Ищет вид в iNaturalist и GBIF. Возвращает:
      {query, name, family, inat_id, gbif_key}
    или None.
    """
    res = {"query": query, "name": None, "family": None,
           "inat_id": None, "gbif_key": None}

    # --- iNaturalist ---
    try:
        r = session.get(f"{INAT_API}/taxa",
                        params={"q": query, "rank": "species", "per_page": 5},
                        timeout=30)
        r.raise_for_status()
        items = r.json().get("results", [])
        if items:
            t = items[0]
            res["name"] = t.get("name") or query
            res["inat_id"] = t.get("id")
            for anc in t.get("ancestors", []):
                if anc.get("rank") == "family":
                    res["family"] = anc.get("name")
                    break
    except Exception as e:
        logger.warning(f"iNat lookup «{query}» не удался: {e}")

    # --- GBIF ---
    try:
        name_for_gbif = res["name"] or query
        r = session.get(f"{GBIF_API}/species/match",
                        params={"name": name_for_gbif}, timeout=30)
        r.raise_for_status()
        g = r.json()
        if g.get("matchType") and g["matchType"] != "NONE":
            res["gbif_key"] = g.get("usageKey")
            res["name"] = res["name"] or g.get("scientificName")
            res["family"] = res["family"] or g.get("family")
    except Exception as e:
        logger.warning(f"GBIF match «{query}» не удался: {e}")

    if not res["name"]:
        return None
    res["family"] = res["family"] or "Unknown_family"
    return res


# ============================================================
#                    ИСТОЧНИКИ URL-ОВ
# ============================================================
def inat_iter_urls(taxon_id: int, session: requests.Session, max_pages: int = 200):
    """Генератор large-URL-ов research-grade наблюдений."""
    for page in range(1, max_pages + 1):
        try:
            r = session.get(f"{INAT_API}/observations", params={
                "taxon_id": taxon_id,
                "photos": "true",
                "quality_grade": "research",
                "per_page": 200,
                "page": page,
                "order_by": "votes",
            }, timeout=90)
            r.raise_for_status()
            data = r.json()
        except Exception as e:
            logger.warning(f"iNat observations p{page}: {e}")
            time.sleep(5)
            continue

        results = data.get("results", [])
        if not results:
            return

        for obs in results:
            for ph in obs.get("photos", []):
                url = ph.get("url")
                if not url:
                    continue
                if not is_allowed_license(ph.get("license_code")):
                    continue
                yield url.replace("/square.", "/large.")

        time.sleep(0.7)  # ~60 запросов/мин


def gbif_iter_urls(taxon_key: int, session: requests.Session,
                   max_offset: int = 20000):
    """Генератор URL-ов изображений из GBIF occurrence search."""
    offset = 0
    while offset < max_offset:
        try:
            r = session.get(f"{GBIF_API}/occurrence/search", params={
                "taxonKey": taxon_key,
                "mediaType": "StillImage",
                "limit": 300,
                "offset": offset,
            }, timeout=90)
            r.raise_for_status()
            data = r.json()
        except Exception as e:
            logger.warning(f"GBIF offset {offset}: {e}")
            time.sleep(5)
            break

        results = data.get("results", [])
        if not results:
            break

        for occ in results:
            for m in occ.get("media", []):
                url = m.get("identifier")
                if not url:
                    continue
                if not is_allowed_license(m.get("license")):
                    continue
                yield url

        offset += len(results)
        if data.get("endOfRecords"):
            break
        time.sleep(0.3)


# ============================================================
#                       СКАЧИВАНИЕ
# ============================================================
def download_image(url: str, out_dir: Path,
                   session: requests.Session, timeout: int = 60) -> Path | None:
    """Скачивает URL → out_dir/<md5>.<ext>. Возвращает путь или None."""
    h = hashlib.md5(url.encode()).hexdigest()

    # уже есть?
    for ext in IMG_EXTS:
        p = out_dir / f"{h}{ext}"
        if p.exists() and p.stat().st_size > 2048:
            return p

    try:
        r = session.get(url, timeout=timeout, stream=True)
        if r.status_code != 200:
            return None
        ct = (r.headers.get("Content-Type") or "").lower()
        if "image" not in ct and not url.lower().endswith(tuple(IMG_EXTS)):
            return None

        if "png" in ct:
            ext = ".png"
        elif "webp" in ct:
            ext = ".webp"
        elif "jpeg" in ct or "jpg" in ct:
            ext = ".jpg"
        else:
            guess = os.path.splitext(url.split("?")[0])[1].lower()
            ext = guess if guess in IMG_EXTS else ".jpg"

        out_path = out_dir / f"{h}{ext}"
        tmp_path = out_dir / f"{h}{ext}.part"

        with open(tmp_path, "wb") as f:
            for chunk in r.iter_content(65536):
                f.write(chunk)

        if tmp_path.stat().st_size < 2048:
            tmp_path.unlink(missing_ok=True)
            return None

        tmp_path.rename(out_path)
        return out_path
    except Exception:
        try:
            (out_dir / f"{h}.part").unlink(missing_ok=True)
        except Exception:
            pass
        return None


def collect_species(taxon: dict, session: requests.Session, target: int) -> Path:
    """Скачивает фото одного вида во все источники, куда сможет."""
    family = safe_name(taxon["family"])
    name = safe_name(taxon["name"])
    out_dir = RAW_DIR / family / name
    out_dir.mkdir(parents=True, exist_ok=True)

    # убираем недокачанные .part
    for p in out_dir.glob("*.part"):
        p.unlink(missing_ok=True)

    have = len(list_images(out_dir))
    logger.info(f"[{taxon['query']}] → {family}/{name}   (уже есть: {have})")
    if have >= target:
        logger.info(f"    достаточно ({have}/{target}), пропуск")
        return out_dir

    attempted_file = out_dir / ".attempted_urls.txt"
    attempted: set[str] = set()
    if attempted_file.exists():
        attempted = set(attempted_file.read_text(
            encoding="utf-8").splitlines())

    a_fp = open(attempted_file, "a", encoding="utf-8")
    downloaded = have

    def try_source(urls, label):
        nonlocal downloaded
        for url in urls:
            if downloaded >= target:
                return
            if url in attempted:
                continue
            attempted.add(url)
            a_fp.write(url + "\n")
            a_fp.flush()

            if download_image(url, out_dir, session):
                downloaded += 1
                if downloaded % 25 == 0 or downloaded == target:
                    logger.info(f"    {downloaded}/{target}")
            time.sleep(DOWNLOAD_SLEEP)

    try:
        if downloaded < target and taxon.get("inat_id"):
            logger.info("    источник: iNaturalist")
            try_source(inat_iter_urls(taxon["inat_id"], session), "iNat")

        if downloaded < target and taxon.get("gbif_key"):
            logger.info("    источник: GBIF")
            try_source(gbif_iter_urls(taxon["gbif_key"], session), "GBIF")
    finally:
        a_fp.close()

    logger.info(f"    итог: {downloaded}/{target}")
    return out_dir


# ============================================================
#                     ПОСТОБРАБОТКА
# ============================================================
def postprocess_resize(raw_root: Path):
    if not HAS_PIL:
        logger.warning("Pillow не установлен — пропускаю ресайз. "
                       "Установите: pip install Pillow")
        return
    logger.info("=== Ресайз → processed/ ===")
    for sp_dir in iter_species_dirs(raw_root):
        rel = sp_dir.relative_to(raw_root)
        out_dir = PROCESSED_DIR / rel
        out_dir.mkdir(parents=True, exist_ok=True)

        files = list_images(sp_dir)
        done = 0
        for p in files:
            out_path = out_dir / (p.stem + ".jpg")
            if out_path.exists():
                continue
            try:
                with Image.open(p) as im:
                    im = im.convert("RGB")
                    im.thumbnail((IMAGE_SIZE, IMAGE_SIZE))
                    im.save(out_path, "JPEG", quality=JPEG_QUALITY)
                    done += 1
            except Exception:
                # битый файл — удаляем из raw
                try:
                    p.unlink()
                except Exception:
                    pass
        logger.info(f"  {rel}: +{done} (всего {len(files)})")


def dedup_processed(processed_root: Path):
    if not HAS_IMAGEHASH:
        logger.warning("ImageHash не установлен — пропускаю дедуп. "
                       "Установите: pip install ImageHash")
        return
    logger.info("=== Дедуп (perceptual hash) ===")
    for sp_dir in iter_species_dirs(processed_root):
        hashes: list[tuple[object, Path]] = []
        removed = 0
        for p in sorted(sp_dir.glob("*.jpg")):
            try:
                h = imagehash.phash(Image.open(p))
            except Exception:
                continue
            is_dup = False
            for eh, _ in hashes:
                if h - eh <= PHASH_DISTANCE:
                    is_dup = True
                    break
            if is_dup:
                p.unlink()
                removed += 1
            else:
                hashes.append((h, p))
        logger.info(
            f"  {sp_dir.name}: удалено дублей {removed}, осталось {len(hashes)}")


def build_split(processed_root: Path, split_root: Path, ratios):
    logger.info("=== Сплит train/val/test ===")
    if split_root.exists():
        shutil.rmtree(split_root)
    for part in ("train", "val", "test"):
        (split_root / part).mkdir(parents=True, exist_ok=True)

    import random
    for sp_dir in iter_species_dirs(processed_root):
        family = sp_dir.parent.name
        species = sp_dir.name
        files = sorted(sp_dir.glob("*.jpg"))
        random.Random(42).shuffle(files)

        n = len(files)
        n_val = int(n * ratios[1])
        n_test = int(n * ratios[2])
        n_train = n - n_val - n_test

        buckets = {
            "train": files[:n_train],
            "val":   files[n_train:n_train + n_val],
            "test":  files[n_train + n_val:],
        }
        for part, fl in buckets.items():
            out = split_root / part / family / species
            out.mkdir(parents=True, exist_ok=True)
            for p in fl:
                dst = out / p.name
                if dst.exists():
                    continue
                # пытаемся симлинк, на Windows без прав — копируем
                try:
                    os.symlink(p.resolve(), dst)
                except (OSError, NotImplementedError):
                    shutil.copy2(p, dst)
        logger.info(f"  {family}/{species}: {n_train}/{n_val}/{n_test}")


# ============================================================
#                         СПИСОК ВИДОВ
# ============================================================
SPECIES_TEMPLATE = """\
# Список растений для сбора — по одному названию на строку.
# Можно указывать научное название (лучше) или обиходное.
# Строки, начинающиеся с #, игнорируются.
#
# Просто допишите новые названия и запустите скрипт снова —
# уже скачанное он не тронет, а новое докачает.
#
# Примеры:
Quercus robur
Quercus rubra
Acer platanoides
Acer campestre
Betula pendula
Tilia cordata
Pinus sylvestris
Picea abies
"""


def load_species(cli_species: list[str] | None = None) -> list[str]:
    if not SPECIES_FILE.exists():
        SPECIES_FILE.write_text(SPECIES_TEMPLATE, encoding="utf-8")
        logger.info(f"Создан шаблон {SPECIES_FILE} — "
                    f"отредактируйте его и запустите снова.")
    lines = SPECIES_FILE.read_text(encoding="utf-8").splitlines()
    species = [l.strip() for l in lines
               if l.strip() and not l.startswith("#")]

    if cli_species:
        for s in cli_species:
            if s not in species:
                species.append(s)
    return species


# ============================================================
#                        ИТОГОВАЯ СВОДКА
# ============================================================
def print_summary():
    if not PROCESSED_DIR.exists():
        return
    logger.info("=== Сводка по processed/ ===")
    total = 0
    for sp_dir in iter_species_dirs(PROCESSED_DIR):
        n = len(list(sp_dir.glob("*.jpg")))
        total += n
        rel = sp_dir.relative_to(PROCESSED_DIR)
        mark = "" if n >= 200 else "  ⚠ мало"
        logger.info(f"  {rel}: {n}{mark}")
    logger.info(f"  ИТОГО: {total} изображений")


# ============================================================
#                            MAIN
# ============================================================
def main():
    setup_logging()

    ap = argparse.ArgumentParser(
        description="Сборщик фотографий растений для датасета ИИ")
    ap.add_argument("--target", type=int, default=TARGET_PER_SPECIES,
                    help=f"минимум фото на вид (по умолчанию {TARGET_PER_SPECIES})")
    ap.add_argument("--species", action="append", default=None,
                    help="доп. вид(ы) в CLI, не трогая species.txt "
                         "(можно указывать несколько раз)")
    ap.add_argument("--only-download", action="store_true",
                    help="только скачать, без ресайза/дедупа/сплита")
    ap.add_argument("--only-process", action="store_true",
                    help="только постобработка, без скачивания")
    ap.add_argument("--skip-split", action="store_true",
                    help="не строить train/val/test")
    args = ap.parse_args()

    for d in (RAW_DIR, PROCESSED_DIR, SPLIT_DIR):
        d.mkdir(parents=True, exist_ok=True)

    session = requests.Session()
    session.headers.update(HEADERS)

    # ---------- СКАЧИВАНИЕ ----------
    if not args.only_process:
        species = load_species(args.species)
        if not species:
            logger.warning("Список видов пуст — нечего собирать.")
        logger.info(f"Видов в списке: {len(species)}")
        for q in species:
            try:
                taxon = resolve_taxon(q, session)
                if not taxon:
                    logger.warning(f"Не удалось определить: {q}")
                    continue
                collect_species(taxon, session, args.target)
            except KeyboardInterrupt:
                logger.info("Прервано пользователем — выхожу из сбора.")
                break
            except Exception as e:
                logger.exception(f"Ошибка на «{q}»: {e}")

    # ---------- ПОСТОБРАБОТКА ----------
    if not args.only_download:
        postprocess_resize(RAW_DIR)
        dedup_processed(PROCESSED_DIR)
        if not args.skip_split:
            build_split(PROCESSED_DIR, SPLIT_DIR, SPLIT_RATIOS)
        print_summary()

    logger.info("Готово. Данные в: %s", DATASET_DIR)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nПрервано. Запустите снова — продолжит с того же места.")
