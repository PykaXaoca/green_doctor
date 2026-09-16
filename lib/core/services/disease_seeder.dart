import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database/database.dart';

/// Сервис импорта справочника болезней из ассета.
///
/// Логика:
///  1. Читаем JSON, считаем число болезней.
///  2. Смотрим, сколько сейчас в БД.
///  3. Если в JSON больше, чем в БД (или импорт ещё не выполнялся) —
///     переимпортируем через `insertAllOnConflictUpdate`. Старые
///     записи обновляются, новые добавляются, ничего не удаляется.
///
/// Если ассет отсутствует или повреждён — сидер не бросает исключение,
/// а помечает импорт как выполненный и продолжает работу.
class DiseaseSeeder {
  DiseaseSeeder(this._db);

  final AppDatabase _db;

  static const String _assetPath = 'assets/data/plant_diseases.json';
  static const String _metaKey = 'diseases_imported';

  Future<int> seedIfNeeded() async {
    String rawJson;
    try {
      rawJson = await rootBundle.loadString(_assetPath);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DiseaseSeeder] Ассет $_assetPath не найден: $e');
      }
      await _db.appMetaDao.setValue(_metaKey, 'true');
      return 0;
    }

    try {
      final list = jsonDecode(rawJson) as List<dynamic>;
      final expectedCount = list.length;

      final all = await _db.diseaseDao.getAll();
      final actualCount = all.length;

      final done = await _db.appMetaDao.getValue(_metaKey);
      final alreadyImported = done == 'true';

      // Всё актуально — ничего не делаем.
      if (alreadyImported && actualCount >= expectedCount) {
        return 0;
      }

      return await _parseAndInsert(rawJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DiseaseSeeder] Ошибка разбора JSON: $e');
      }
      await _db.appMetaDao.setValue(_metaKey, 'true');
      return 0;
    }
  }

  Future<int> seed() async {
    String rawJson;
    try {
      rawJson = await rootBundle.loadString(_assetPath);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DiseaseSeeder] Ассет $_assetPath не найден: $e');
      }
      await _db.appMetaDao.setValue(_metaKey, 'true');
      return 0;
    }

    try {
      return await _parseAndInsert(rawJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DiseaseSeeder] Ошибка разбора JSON: $e');
      }
      await _db.appMetaDao.setValue(_metaKey, 'true');
      return 0;
    }
  }

  Future<int> seedFromJsonString(String rawJson) async {
    return _parseAndInsert(rawJson);
  }

  Future<int> _parseAndInsert(String rawJson) async {
    final list = jsonDecode(rawJson) as List<dynamic>;

    final companions = list.map((item) {
      final map = item as Map<String, dynamic>;
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

    if (kDebugMode) {
      debugPrint(
        '[DiseaseSeeder] Импортировано болезней: ${companions.length}',
      );
    }

    return companions.length;
  }
}
