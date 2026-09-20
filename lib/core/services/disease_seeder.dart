import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/database.dart';
import 'asset_folder_loader.dart';

/// Сервис импорта справочника болезней из папки ассетов.
///
/// Источник: `assets/data/diseases/<id>.json` — по одному файлу
/// на болезнь.
///
/// Логика:
///  1. Читаем все JSON-файлы из папки.
///  2. Смотрим, сколько сейчас в БД и какая версия импорта.
///  3. Если в JSON больше, чем в БД (или версия устарела, или
///     импорт ещё не выполнялся) — переимпортируем через
///     `insertAllOnConflictUpdate`. Старые записи обновляются,
///     новые добавляются, ничего не удаляется.
///
/// При каждом изменении содержимого `assets/data/diseases/**`
/// увеличивай [_currentVersion] на 1.
class DiseaseSeeder {
  DiseaseSeeder(this._db);

  final AppDatabase _db;

  static const String _folder = 'assets/data/diseases';
  static const String _metaKey = 'diseases_imported';
  static const String _versionKey = 'diseases_import_version';

  /// История:
  ///   1 — монолитный `plant_diseases.json`
  ///   2 — переезд на папку `diseases/`
  static const int _currentVersion = 2;

  Future<int> seedIfNeeded() async {
    List<Map<String, dynamic>> items;
    try {
      final byId = await loadJsonObjectsByIdFromFolder(_folder);
      items = byId.values.toList(growable: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DiseaseSeeder] Ошибка чтения папки $_folder: $e');
      }
      await _db.appMetaDao.setValue(_metaKey, 'true');
      return 0;
    }

    final expectedCount = items.length;

    final all = await _db.diseaseDao.getAll();
    final actualCount = all.length;

    final done = await _db.appMetaDao.getValue(_metaKey);
    final version = await _db.appMetaDao.getValue(_versionKey);

    final alreadyImported = done == 'true';
    final versionMatches = version == _currentVersion.toString();
    final countMatches = actualCount >= expectedCount;

    if (alreadyImported && versionMatches && countMatches) {
      if (kDebugMode) {
        debugPrint(
          '[DiseaseSeeder] Пропуск: уже импортировано '
          '(v$version, $actualCount болезней)',
        );
      }
      return 0;
    }

    return _insertItems(items);
  }

  Future<int> seed() async {
    final byId = await loadJsonObjectsByIdFromFolder(_folder);
    final items = byId.values.toList(growable: false);
    return _insertItems(items);
  }

  /// Совместимость: импорт из строки. Ожидается JSON-массив
  /// объектов болезней (как раньше).
  Future<int> seedFromJsonString(String rawJson) async {
    final list = jsonDecode(rawJson) as List<dynamic>;
    final items = list.cast<Map<String, dynamic>>();
    return _insertItems(items);
  }

  Future<int> _insertItems(List<Map<String, dynamic>> items) async {
    final companions = items.map((map) {
      return PlantDiseasesCompanion(
        id: Value(map['id'] as String),
        name: Value(map['name'] as String),
        description: Value(map['description'] as String?),
        symptomsJson: Value(map['symptoms_json'] as String?),
        treatmentPlanJson: Value(map['treatment_plan_json'] as String?),
        modelLabelId: Value(map['model_label_id'] as int?),
        isPremium: Value((map['is_premium'] as bool?) ?? false),
      );
    }).toList();

    await _db.diseaseDao.insertAll(companions);
    await _db.appMetaDao.setValue(_metaKey, 'true');
    await _db.appMetaDao.setValue(_versionKey, _currentVersion.toString());

    if (kDebugMode) {
      debugPrint(
        '[DiseaseSeeder] Импорт v$_currentVersion: '
        'болезней ${companions.length}',
      );
    }

    return companions.length;
  }
}
