import 'package:drift/drift.dart';

// ============================================================
// 1. Пользователи приложения (локальный профиль)
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
// 2. Справочник видов растений
// ============================================================
class PlantSpecies extends Table {
  TextColumn get id => text()();
  TextColumn get commonName => text()();
  TextColumn get scientificName => text()();
  TextColumn get family => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get careGuideJson => text().nullable()();
  IntColumn get defaultWateringDays => integer().nullable()();
  IntColumn get fertilizingFrequencyDays => integer().nullable()();
  TextColumn get fertilizerType => text().nullable()();
  TextColumn get lightRequirements => text().nullable()();
  IntColumn get minTemperature => integer().nullable()();
  IntColumn get maxTemperature => integer().nullable()();
  IntColumn get humidityMin => integer().nullable()();
  IntColumn get humidityMax => integer().nullable()();
  TextColumn get soilType => text().nullable()();
  TextColumn get soilMoisture => text().nullable()();
  IntColumn get repottingFrequencyMonths => integer().nullable()();
  TextColumn get pruningInfo => text().nullable()();
  TextColumn get toxicity => text().nullable()();
  TextColumn get modelLabelId => text().nullable()();
  TextColumn get imageAssetPath => text().nullable()();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// 3. Растения пользователя
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

  // --- Семена и рассада ---
  TextColumn get seedPacketImagePath => text().nullable()();
  TextColumn get seedVarietyName => text().nullable()();
  TextColumn get plantingLocation => text().nullable()();
  DateTimeColumn get seedlingPlantingDate => dateTime().nullable()();

  // --- Состояние ухода ---
  DateTimeColumn get lastWateredAt => dateTime().nullable()();
  DateTimeColumn get lastFertilizedAt => dateTime().nullable()();

  /// Дата последней пересадки. Если null — берётся [createdAt]
  /// в расчёте следующей пересадки.
  DateTimeColumn get lastRepottedAt => dateTime().nullable()();

  DateTimeColumn get nextWaterDue => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

// ============================================================
// 4. События ухода
// ============================================================
class CareEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer().references(Plants, #id)();
  TextColumn get type => text()();
  DateTimeColumn get performedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
}

// ============================================================
// 5. Напоминания
// ============================================================
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer().references(Plants, #id)();
  TextColumn get type => text()();
  DateTimeColumn get dueAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isRepeating => boolean().withDefault(const Constant(false))();
  IntColumn get repeatIntervalDays => integer().nullable()();
  IntColumn get notificationId => integer().nullable()();
}

// ============================================================
// 6. Кеш погоды
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
// 7. Справочник болезней
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
// 8. Диагнозы
// ============================================================
class Diagnoses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer().nullable().references(Plants, #id)();
  TextColumn get diseaseId =>
      text().nullable().references(PlantDiseases, #id)();
  TextColumn get imagePath => text().nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
}

// ============================================================
// 9. Шаги лечения
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
// 10. Достижения (справочник)
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
// 11. Достижения пользователя
// ============================================================
class UserAchievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(AppUsers, #id)();
  TextColumn get achievementCode => text().references(Achievements, #code)();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================
// 12. История XP
// ============================================================
class UserXpEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(AppUsers, #id)();
  IntColumn get amount => integer()();
  TextColumn get reason => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================
// 13. Метаданные приложения
// ============================================================
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
