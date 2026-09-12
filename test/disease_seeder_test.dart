import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/database/database.dart';
import 'package:pocket_botanist/core/services/disease_seeder.dart';

const _sampleJson = '''
[
  {
    "id": "test_disease_a",
    "name": "Тестовая болезнь A",
    "description": "Описание A",
    "symptoms_json": "[]",
    "treatment_plan_json": "[]",
    "model_label_id": 0,
    "is_premium": false
  },
  {
    "id": "test_disease_b",
    "name": "Тестовая болезнь B",
    "description": "Описание B",
    "symptoms_json": "[]",
    "treatment_plan_json": "[]",
    "model_label_id": 1,
    "is_premium": true
  }
]
''';

void main() {
  late AppDatabase db;
  late DiseaseSeeder seeder;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    seeder = DiseaseSeeder(db);
  });

  tearDown(() async => db.close());

  test('Импорт вставляет записи', () async {
    final count = await seeder.seedFromJsonString(_sampleJson);
    expect(count, 2);

    final all = await db.diseaseDao.getAll();
    expect(all.length, 2);
    expect(
      all.firstWhere((d) => d.id == 'test_disease_a').name,
      'Тестовая болезнь A',
    );
    expect(all.firstWhere((d) => d.id == 'test_disease_b').isPremium, true);
  });

  test('После импорта флаг diseases_imported=true', () async {
    await seeder.seedFromJsonString(_sampleJson);
    final value = await db.appMetaDao.getValue('diseases_imported');
    expect(value, 'true');
  });
}
