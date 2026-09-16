import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database/database.dart';

/// Сервис для импорта справочника видов растений из ассетов.
///
/// Поддерживает несколько JSON-файлов: они мержатся в один список.
/// Это позволяет расширять справочник, не раздувая один файл.
class SpeciesImporter {
  SpeciesImporter(this._db);

  final AppDatabase _db;

  /// Порядок файлов не важен. Если какого-то нет — пропускается.
  static const List<String> _assetPaths = [
    'assets/data/plant_species.json',
    'assets/data/plant_species_2.json',
    'assets/data/plant_species_3.json',
    'assets/data/plant_species_4.json',
    'assets/data/plant_species_5.json',
  ];

  static const String _metaKey = 'species_imported';

  Future<int> importIfNeeded() async {
    final items = await _loadAllItems();
    final expectedCount = items.length;

    final all = await _db.speciesDao.getAll();
    final actualCount = all.length;

    final done = await _db.appMetaDao.getValue(_metaKey);
    final alreadyImported = done == 'true';

    if (alreadyImported && actualCount >= expectedCount) {
      return 0;
    }

    return _insertItems(items);
  }

  Future<int> import() async {
    final items = await _loadAllItems();
    return _insertItems(items);
  }

  Future<int> importFromJsonString(String rawJson) async {
    final list = jsonDecode(rawJson) as List<dynamic>;
    return _insertItems(list);
  }

  Future<List<dynamic>> _loadAllItems() async {
    final result = <dynamic>[];
    for (final path in _assetPaths) {
      try {
        final raw = await rootBundle.loadString(path);
        final list = jsonDecode(raw) as List<dynamic>;
        result.addAll(list);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SpeciesImporter] Файл $path не прочитан: $e');
        }
      }
    }
    return result;
  }

  Future<int> _insertItems(List<dynamic> items) async {
    final companions = items.map((item) {
      final map = item as Map<String, dynamic>;
      return PlantSpeciesCompanion(
        id: Value(map['id'] as String),
        commonName: Value(map['common_name'] as String),
        scientificName: Value(map['scientific_name'] as String),
        family: Value(map['family'] as String?),
        category: Value(map['category'] as String?),
        description: Value(map['description'] as String?),
        careGuideJson: Value(map['care_guide_json'] as String?),
        defaultWateringDays: Value(map['default_watering_days'] as int?),
        fertilizingFrequencyDays: Value(
          map['fertilizing_frequency_days'] as int?,
        ),
        fertilizerType: Value(map['fertilizer_type'] as String?),
        lightRequirements: Value(map['light_requirements'] as String?),
        minTemperature: Value(map['min_temperature'] as int?),
        maxTemperature: Value(map['max_temperature'] as int?),
        humidityMin: Value(map['humidity_min'] as int?),
        humidityMax: Value(map['humidity_max'] as int?),
        soilType: Value(map['soil_type'] as String?),
        soilMoisture: Value(map['soil_moisture'] as String?),
        repottingFrequencyMonths: Value(
          map['repotting_frequency_months'] as int?,
        ),
        pruningInfo: Value(map['pruning_info'] as String?),
        toxicity: Value(map['toxicity'] as String?),
        modelLabelId: Value(map['model_label_id'] as String?),
        imageAssetPath: Value(map['image_asset_path'] as String?),
        isPremium: Value((map['is_premium'] as bool?) ?? false),
      );
    }).toList();

    await _db.speciesDao.insertAll(companions);
    await _db.appMetaDao.setValue(_metaKey, 'true');

    if (kDebugMode) {
      debugPrint('[SpeciesImporter] Импортировано видов: ${companions.length}');
    }

    return companions.length;
  }
}
