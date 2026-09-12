import 'package:drift/drift.dart';

// ============================================================
// 1. РџРѕР»СЊР·РѕРІР°С‚РµР»Рё РїСЂРёР»РѕР¶РµРЅРёСЏ (Р»РѕРєР°Р»СЊРЅС‹Р№ РїСЂРѕС„РёР»СЊ)
// ============================================================
class AppUsers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName =>
      text().withLength(min: 1, max: 100).nullable()();
  TextColumn get avatarPath => text().nullable()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  TextColumn get subscriptionTier =>
      text().withDefault(const Constant('free'))();
  DateTimeColumn get subscriptionExpiry => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================
// 2. РЎРїСЂР°РІРѕС‡РЅРёРє РІРёРґРѕРІ СЂР°СЃС‚РµРЅРёР№
// ============================================================
class PlantSpecies extends Table {
  TextColumn get id => text()();
  TextColumn get commonName => text()();
  TextColumn get scientificName => text()();
  TextColumn get family => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get careGuideJson => text().nullable()();
  IntColumn get defaultWateringDays => integer().nullable()();
  TextColumn get lightRequirements => text().nullable()();
  IntColumn get minTemperature => integer().nullable()();
  IntColumn get maxTemperature => integer().nullable()();
  IntColumn get humidityMin => integer().nullable()();
  IntColumn get humidityMax => integer().nullable()();
  TextColumn get soilType => text().nullable()();
  TextColumn get toxicity => text().nullable()();
  TextColumn get modelLabelId => text().nullable()();
  TextColumn get imageAssetPath => text().nullable()();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// 3. Р Р°СЃС‚РµРЅРёСЏ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ
// ============================================================
class Plants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(AppUsers, #id)();
  TextColumn get speciesId => text().nullable().references(PlantSpecies, #id)();
  TextColumn get customName => text().withLength(min: 1, max: 100)();
  TextColumn get imagePath => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get lightDirection => text().nullable()();
  IntColumn get wateringFrequencyDays => integer().nullable()();
  IntColumn get fertilizingFrequencyDays => integer().nullable()();
  TextColumn get soilType => text().nullable()();
  TextColumn get potSize => text().nullable()();
  TextColumn get notes => text().nullable()();

  // --- РџРѕР»СЏ РґР»СЏ СЃРµРјСЏРЅ Рё СЂР°СЃСЃР°РґС‹ (nullable) ---
  TextColumn get seedPacketImagePath => text().nullable()();
  TextColumn get seedVarietyName => text().nullable()();
  TextColumn get plantingLocation => text().nullable()();
  DateTimeColumn get seedlingPlantingDate => dateTime().nullable()();

  // --- РЎРѕСЃС‚РѕСЏРЅРёРµ СѓС…РѕРґР° ---
  DateTimeColumn get lastWateredAt => dateTime().nullable()();
  DateTimeColumn get lastFertilizedAt => dateTime().nullable()();
  DateTimeColumn get nextWaterDue => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

// ============================================================
// 4. РЎРѕР±С‹С‚РёСЏ СѓС…РѕРґР° (Р¶СѓСЂРЅР°Р»)
// ============================================================
class CareEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer().references(Plants, #id)();
  TextColumn get type => text()(); // watering, fertilizing, misting, repotting
  DateTimeColumn get performedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
}

// ============================================================
// 5. РќР°РїРѕРјРёРЅР°РЅРёСЏ
// ============================================================
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer().references(Plants, #id)();
  TextColumn get type =>
      text()(); // watering, fertilizing, diagnosis, treatment
  DateTimeColumn get dueAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isRepeating => boolean().withDefault(const Constant(false))();
  IntColumn get repeatIntervalDays => integer().nullable()();
  IntColumn get notificationId => integer().nullable()();
}

// ============================================================
// 6. РљРµС€ РїРѕРіРѕРґС‹
// ============================================================
class WeatherCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime()();
}

// ============================================================
// 7. РЎРїСЂР°РІРѕС‡РЅРёРє Р±РѕР»РµР·РЅРµР№
// ============================================================
class PlantDiseases extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get symptomsJson => text().nullable()();
  TextColumn get treatmentPlanJson => text().nullable()();
  IntColumn get modelLabelId => integer().nullable()();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// 8. Р”РёР°РіРЅРѕР·С‹
// ============================================================
class Diagnoses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer().nullable().references(Plants, #id)();
  TextColumn get diseaseId =>
      text().nullable().references(PlantDiseases, #id)();
  TextColumn get imagePath => text().nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('active'))(); // active, resolved
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
}

// ============================================================
// 9. РЁР°РіРё Р»РµС‡РµРЅРёСЏ
// ============================================================
class TreatmentSteps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get diagnosisId => integer().references(Diagnoses, #id)();
  IntColumn get stepNumber => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

// ============================================================
// 10. Р”РѕСЃС‚РёР¶РµРЅРёСЏ (СЃРїСЂР°РІРѕС‡РЅРёРє)
// ============================================================
class Achievements extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get iconAsset => text().nullable()();
  IntColumn get rewardXp => integer().withDefault(const Constant(0))();
  TextColumn get criteriaJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {code};
}

// ============================================================
// 11. Р”РѕСЃС‚РёР¶РµРЅРёСЏ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ (РїРѕР»СѓС‡РµРЅРЅС‹Рµ)
// ============================================================
class UserAchievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(AppUsers, #id)();
  TextColumn get achievementCode => text().references(Achievements, #code)();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================
// 12. РСЃС‚РѕСЂРёСЏ РЅР°С‡РёСЃР»РµРЅРёСЏ XP
// ============================================================
class UserXpEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(AppUsers, #id)();
  IntColumn get amount => integer()();
  TextColumn get reason => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================
// 13. РњРµС‚Р°РґР°РЅРЅС‹Рµ РїСЂРёР»РѕР¶РµРЅРёСЏ (key-value РґР»СЏ РІРЅСѓС‚СЂРµРЅРЅРµРіРѕ СЃРѕСЃС‚РѕСЏРЅРёСЏ)
// ============================================================
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

