import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/database/database.dart';
import 'package:pocket_botanist/core/services/species_importer.dart';

const _sampleJson = '''
[
  {
    "id": "test_plant_a",
    "common_name": "Тестовое растение A",
    "scientific_name": "Testus plantus",
    "family": "Testaceae",
    "description": "Описание A",
    "default_watering_days": 7,
    "light_requirements": "Яркий свет",
    "min_temperature": 15,
    "max_temperature": 25,
    "humidity_min": 40,
    "humidity_max": 60,
    "soil_type": "Универсальный",
    "toxicity": "Безопасно",
    "model_label_id": "test_a",
    "image_asset_path": "assets/images/species/test_a.png",
    "is_premium": false,
    "care_guide_json": "{}"
  },
  {
    "id": "test_plant_b",
    "common_name": "Тестовое растение B",
    "scientific_name": "Testus b",
    "family": "Testaceae",
    "description": "Описание B",
    "default_watering_days": 14,
    "light_requirements": "Полутень",
    "min_temperature": 10,
    "max_temperature": 28,
    "humidity_min": 30,
    "humidity_max": 50,
    "soil_type": "Кактусовый",
    "toxicity": "Токсично",
    "model_label_id": "test_b",
    "image_asset_path": "assets/images/species/test_b.png",
    "is_premium": true,
    "care_guide_json": "{}"
  }
]
''';

void main() {
  late AppDatabase db;
  late SpeciesImporter importer;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    importer = SpeciesImporter(db);
  });

  tearDown(() async => db.close());

  test('Импорт вставляет записи в plant_species', () async {
    final count = await importer.importFromJsonString(_sampleJson);
    expect(count, 2);

    final all = await db.speciesDao.getAll();
    expect(all.length, 2);
    expect(
      all.firstWhere((s) => s.id == 'test_plant_a').commonName,
      'Тестовое растение A',
    );
    expect(all.firstWhere((s) => s.id == 'test_plant_b').isPremium, true);
  });

  test('После импорта флаг species_imported=true', () async {
    await importer.importFromJsonString(_sampleJson);
    final value = await db.appMetaDao.getValue('species_imported');
    expect(value, 'true');
  });

  test('getNonPremium возвращает только бесплатные виды', () async {
    await importer.importFromJsonString(_sampleJson);
    final free = await db.speciesDao.getNonPremium();
    expect(free.length, 1);
    expect(free.first.id, 'test_plant_a');
  });

  test('searchByName находит по частичному совпадению', () async {
    await importer.importFromJsonString(_sampleJson);
    final result = await db.speciesDao.searchByName('растение A');
    expect(result.length, 1);
    expect(result.first.id, 'test_plant_a');
  });
}
