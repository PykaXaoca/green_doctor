import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database/database.dart';

/// Сервис для импорта справочника видов растений из ассета при первом запуске.
class SpeciesImporter {
  SpeciesImporter(this._db);

  final AppDatabase _db;

  static const String _assetPath = 'assets/data/plant_species.json';
  static const String _metaKey = 'species_imported';

  /// Импортирует виды растений, если они ещё не были импортированы.
  Future<int> importIfNeeded() async {
    final alreadyImported = await _db.appMetaDao.getValue(_metaKey);
    if (alreadyImported == 'true') {
      return 0;
    }
    return import();
  }

  /// Принудительный импорт из ассета.
  Future<int> import() async {
    final rawJson = await rootBundle.loadString(_assetPath);
    return _parseAndInsert(rawJson);
  }

  /// Импорт из строки JSON (для тестов, без ассетов).
  Future<int> importFromJsonString(String rawJson) async {
    return _parseAndInsert(rawJson);
  }

  Future<int> _parseAndInsert(String rawJson) async {
    final list = jsonDecode(rawJson) as List<dynamic>;

    final companions = list.map((item) {
      final map = item as Map<String, dynamic>;
      return PlantSpeciesCompanion(
        id: Value(map['id'] as String),
        commonName: Value(map['common_name'] as String),
        scientificName: Value(map['scientific_name'] as String),
        family: Value(map['family'] as String?),
        description: Value(map['description'] as String?),
        careGuideJson: Value(map['care_guide_json'] as String?),
        defaultWateringDays: Value(map['default_watering_days'] as int?),
        lightRequirements: Value(map['light_requirements'] as String?),
        minTemperature: Value(map['min_temperature'] as int?),
        maxTemperature: Value(map['max_temperature'] as int?),
        humidityMin: Value(map['humidity_min'] as int?),
        humidityMax: Value(map['humidity_max'] as int?),
        soilType: Value(map['soil_type'] as String?),
        toxicity: Value(map['toxicity'] as String?),
        modelLabelId: Value(map['model_label_id'] as String?),
        imageAssetPath: Value(map['image_asset_path'] as String?),
        isPremium: Value((map['is_premium'] as bool?) ?? false),
      );
    }).toList();

    await _db.speciesDao.insertAll(companions);
    await _db.appMetaDao.setValue(_metaKey, 'true');

    return companions.length;
  }
}
