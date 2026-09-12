/// Описание одного достижения.
class AchievementDef {
  const AchievementDef({
    required this.code,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.rewardXp,
    required this.criterion,
  });

  final String code;
  final String name;
  final String description;
  final String iconAsset;
  final int rewardXp;
  final AchievementCriterion criterion;
}

/// Тип условия для достижения.
enum AchievementCriterion {
  firstPlant,
  fivePlants,
  tenPlants,
  greenThumb, // 10 поливов
  waterMaster, // 50 поливов
  fertilizerPro, // 10 удобрений
  mister, // 20 опрыскиваний
  hundredActions, // 100 событий ухода
  level5,
  level10,
}

/// Каталог достижений приложения.
class AchievementsCatalog {
  AchievementsCatalog._();

  static const List<AchievementDef> all = [
    AchievementDef(
      code: 'first_plant',
      name: 'Первый росток',
      description: 'Добавьте своё первое растение',
      iconAsset: 'assets/icons/achievements/first_plant.png',
      rewardXp: 30,
      criterion: AchievementCriterion.firstPlant,
    ),
    AchievementDef(
      code: 'five_plants',
      name: 'Небольшая коллекция',
      description: 'Выращивайте 5 растений одновременно',
      iconAsset: 'assets/icons/achievements/five_plants.png',
      rewardXp: 50,
      criterion: AchievementCriterion.fivePlants,
    ),
    AchievementDef(
      code: 'ten_plants',
      name: 'Настоящий садовод',
      description: 'Соберите коллекцию из 10 растений',
      iconAsset: 'assets/icons/achievements/ten_plants.png',
      rewardXp: 100,
      criterion: AchievementCriterion.tenPlants,
    ),
    AchievementDef(
      code: 'green_thumb',
      name: 'Зелёный палец',
      description: 'Полейте растения 10 раз',
      iconAsset: 'assets/icons/achievements/green_thumb.png',
      rewardXp: 30,
      criterion: AchievementCriterion.greenThumb,
    ),
    AchievementDef(
      code: 'water_master',
      name: 'Мастер полива',
      description: 'Полейте растения 50 раз',
      iconAsset: 'assets/icons/achievements/water_master.png',
      rewardXp: 100,
      criterion: AchievementCriterion.waterMaster,
    ),
    AchievementDef(
      code: 'fertilizer_pro',
      name: 'Гуру удобрений',
      description: 'Подкормите растения 10 раз',
      iconAsset: 'assets/icons/achievements/fertilizer_pro.png',
      rewardXp: 60,
      criterion: AchievementCriterion.fertilizerPro,
    ),
    AchievementDef(
      code: 'mister',
      name: 'Любитель опрыскивания',
      description: 'Опрыскайте растения 20 раз',
      iconAsset: 'assets/icons/achievements/mister.png',
      rewardXp: 40,
      criterion: AchievementCriterion.mister,
    ),
    AchievementDef(
      code: 'hundred_actions',
      name: 'Сто дел',
      description: 'Выполните 100 действий по уходу',
      iconAsset: 'assets/icons/achievements/hundred_actions.png',
      rewardXp: 150,
      criterion: AchievementCriterion.hundredActions,
    ),
    AchievementDef(
      code: 'level_5',
      name: 'Пятый уровень',
      description: 'Достигните 5-го уровня',
      iconAsset: 'assets/icons/achievements/level_5.png',
      rewardXp: 50,
      criterion: AchievementCriterion.level5,
    ),
    AchievementDef(
      code: 'level_10',
      name: 'Десятый уровень',
      description: 'Достигните 10-го уровня',
      iconAsset: 'assets/icons/achievements/level_10.png',
      rewardXp: 200,
      criterion: AchievementCriterion.level10,
    ),
  ];
}
