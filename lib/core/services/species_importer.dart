import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database/database.dart';

/// Сервис импорта справочника видов и сезонного ухода.
///
/// Файлы ищутся автоматически по префиксу:
///   assets/data/plant_species.json, _2.json, _3.json, ...
///   assets/data/seasonal_care.json, _2.json, _3.json, ...
/// Достаточно положить новый файл — код менять не нужно.
///
/// ВАЖНО: при каждом изменении содержимого assets/data/*.json
/// увеличивай [_currentVersion] на 1. Иначе приложение не перезальёт
/// справочник (мета `species_imported` уже стоит в 'true').
class SpeciesImporter {
  SpeciesImporter(this._db);

  final AppDatabase _db;

  static const String _speciesPrefix = 'assets/data/plant_species';
  static const String _seasonalPrefix = 'assets/data/seasonal_care';
  static const String _metaKey = 'species_imported';
  static const String _versionKey = 'species_import_version';

  /// Версия структуры данных. Меняй при обновлении JSON-файлов.
  static const int _currentVersion = 2;

  static const int _maxFiles = 50;

  Future<int> importIfNeeded() async {
    final items = await _loadAllSpecies();
    final expectedCount = items.length;

    final all = await _db.speciesDao.getAll();
    final actualCount = all.length;

    final done = await _db.appMetaDao.getValue(_metaKey);
    final version = await _db.appMetaDao.getValue(_versionKey);

    final alreadyImported = done == 'true';
    final versionMatches = version == _currentVersion.toString();
    final countMatches = actualCount >= expectedCount;

    if (alreadyImported && versionMatches && countMatches) {
      if (kDebugMode) {
        debugPrint(
          '[SpeciesImporter] Пропуск: уже импортировано '
          '(v$version, $actualCount видов)',
        );
      }
      return 0;
    }

    if (kDebugMode) {
      debugPrint(
        '[SpeciesImporter] Переимпорт: '
        'done=$alreadyImported, v=$version (нужно $_currentVersion), '
        'count=$actualCount (нужно $expectedCount)',
      );
    }

    return _insertItems(items);
  }

  Future<int> import() async {
    final items = await _loadAllSpecies();
    return _insertItems(items);
  }

  Future<int> importFromJsonString(String rawJson) async {
    final list = jsonDecode(rawJson) as List<dynamic>;
    return _insertItems(list);
  }

  // ---------- Загрузка ассетов ----------

  Future<List<dynamic>> _loadAllSpecies() async {
    final files = await _loadNumberedJson(_speciesPrefix);
    final result = <dynamic>[];
    for (final entry in files) {
      try {
        final list = jsonDecode(entry.value) as List<dynamic>;
        result.addAll(list);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SpeciesImporter] Ошибка парсинга ${entry.key}: $e');
        }
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> _loadAllSeasonalCare() async {
    final files = await _loadNumberedJson(_seasonalPrefix);
    final result = <String, dynamic>{};
    for (final entry in files) {
      try {
        final map = jsonDecode(entry.value) as Map<String, dynamic>;
        // Внимание: если в файле дублируются ключи, dart:convert оставит
        // последнее значение. Следи за этим в seasonal_care*.json.
        result.addAll(map);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SpeciesImporter] Ошибка парсинга ${entry.key}: $e');
        }
      }
    }
    return result;
  }

  /// Возвращает список (путь, содержимое) для всех существующих файлов
  /// вида: `<prefix>.json`, `<prefix>_2.json`, `<prefix>_3.json`, ...
  /// Останавливается на первом отсутствующем индексе.
  Future<List<MapEntry<String, String>>> _loadNumberedJson(
    String prefix,
  ) async {
    final result = <MapEntry<String, String>>[];

    final first = await _tryLoad('$prefix.json');
    if (first == null) return result;
    result.add(MapEntry('$prefix.json', first));

    for (var i = 2; i <= _maxFiles; i++) {
      final path = '${prefix}_$i.json';
      final raw = await _tryLoad(path);
      if (raw == null) break;
      result.add(MapEntry(path, raw));
    }
    return result;
  }

  Future<String?> _tryLoad(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      return null;
    }
  }

  // ---------- Логика isIndoor ----------

  /// true — комнатное, false — садовое/уличное, null — не определено.
  /// Согласовано: «Зелень и пряности» = садовое (false).
  bool? _detectIndoor(String? category) {
    if (category == null) return null;
    final c = category.toLowerCase().trim();
    if (c.isEmpty) return null;

    // --- Комнатные ---
    if (c.contains('комнатн')) return true;
    if (c.contains('суккулент')) return true;
    if (c.contains('кактус')) return true;
    if (c.contains('пальма')) return true;

    // --- Садовые / уличные ---
    if (c.contains('овощ')) return false;
    if (c.contains('ягодн')) return false;
    if (c.contains('садовое')) return false;
    if (c.contains('садовый')) return false;
    if (c.contains('луковичн')) return false;
    if (c.contains('полев')) return false;
    if (c.contains('декоративный кустарник')) return false;
    if (c.contains('хвойн')) return false;
    if (c.contains('почвопокровн')) return false;
    if (c.contains('вьющиеся')) return false;

    // «Зелень и пряности» — вариант A: садовое по умолчанию
    if (c.contains('зелень') || c.contains('пряност')) return false;

    return null;
  }

  // ---------- Вставка ----------

  Future<int> _insertItems(List<dynamic> items) async {
    final seasonalCare = await _loadAllSeasonalCare();

    var skipped = 0;
    var withSeasonal = 0;

    final companions = <PlantSpeciesCompanion>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) {
        skipped++;
        continue;
      }
      final id = item['id'];
      if (id is! String || id.isEmpty) {
        skipped++;
        continue;
      }

      final category = item['category'] as String?;
      final care = seasonalCare[id];
      if (care != null) withSeasonal++;

      companions.add(
        PlantSpeciesCompanion(
          id: Value(id),
          commonName: Value(item['common_name'] as String? ?? id),
          scientificName: Value(item['scientific_name'] as String? ?? ''),
          family: Value(item['family'] as String?),
          category: Value(category),
          description: Value(item['description'] as String?),
          careGuideJson: Value(item['care_guide_json'] as String?),
          defaultWateringDays: Value(item['default_watering_days'] as int?),
          fertilizingFrequencyDays: Value(
            item['fertilizing_frequency_days'] as int?,
          ),
          fertilizerType: Value(item['fertilizer_type'] as String?),
          lightRequirements: Value(item['light_requirements'] as String?),
          minTemperature: Value(item['min_temperature'] as int?),
          maxTemperature: Value(item['max_temperature'] as int?),
          humidityMin: Value(item['humidity_min'] as int?),
          humidityMax: Value(item['humidity_max'] as int?),
          soilType: Value(item['soil_type'] as String?),
          soilMoisture: Value(item['soil_moisture'] as String?),
          repottingFrequencyMonths: Value(
            item['repotting_frequency_months'] as int?,
          ),
          pruningInfo: Value(item['pruning_info'] as String?),
          toxicity: Value(item['toxicity'] as String?),
          modelLabelId: Value(item['model_label_id'] as String?),
          imageAssetPath: Value(item['image_asset_path'] as String?),
          isPremium: Value((item['is_premium'] as bool?) ?? false),
          isIndoor: Value(_detectIndoor(category) ?? false),
          seasonalCareJson: Value(care == null ? null : jsonEncode(care)),
        ),
      );
    }

    await _db.speciesDao.insertAll(companions);
    await _db.appMetaDao.setValue(_metaKey, 'true');
    await _db.appMetaDao.setValue(_versionKey, _currentVersion.toString());

    if (kDebugMode) {
      debugPrint(
        '[SpeciesImporter] Импорт v$_currentVersion: '
        'видов ${companions.length}, '
        'с сезонкой $withSeasonal, '
        'без сезонки ${companions.length - withSeasonal}, '
        'ключей в seasonal_care ${seasonalCare.length}, '
        'пропущено битых $skipped',
      );
    }
    return companions.length;
  }
}
