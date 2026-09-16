import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/achievements_catalog.dart';
import '../../../../core/database/database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../plants/presentation/providers/plant_providers.dart';

/// Данные профиля: пользователь, статистика, достижения.
class ProfileData {
  const ProfileData({
    required this.user,
    required this.plantCount,
    required this.archivedCount,
    required this.careEventCount,
    required this.careEventsThisMonth,
    required this.daysInApp,
    required this.streakDays,
    required this.unlockedCodes,
    required this.recentXp,
  });

  final AppUser user;

  /// Активные растения.
  final int plantCount;

  /// Растения в архиве.
  final int archivedCount;

  /// Всего событий ухода.
  final int careEventCount;

  /// Событий ухода за текущий календарный месяц.
  final int careEventsThisMonth;

  /// Сколько дней прошло с момента создания профиля.
  final int daysInApp;

  /// Дней подряд, в которые было хотя бы одно событие ухода.
  final int streakDays;

  final Set<String> unlockedCodes;
  final List<UserXpEvent> recentXp;
}

final profileDataProvider = FutureProvider<ProfileData>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final db = ref.watch(databaseProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final plantRepo = ref.watch(plantRepositoryProvider);
  final careRepo = ref.watch(careEventRepositoryProvider);

  var user = await userRepo.getById(userId);
  if (user == null) {
    await userRepo.create(
      const AppUsersCompanion(displayName: Value('Садовод')),
    );
    user = await userRepo.getById(userId);
  }

  final plants = await plantRepo.getByUser(userId);
  final archived = await plantRepo.getArchivedByUser(userId);
  final events = await careRepo.getRecent(10000);
  final unlocked = await userRepo.getUserAchievements(userId);
  final xpHistory = await db.userDao.getXpHistory(userId);
  xpHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  final now = DateTime.now();
  final eventsThisMonth = events.where((e) {
    return e.performedAt.year == now.year && e.performedAt.month == now.month;
  }).length;

  final daysInApp = now.difference(user!.createdAt).inDays;

  final streak = _calculateStreak(events, now);

  return ProfileData(
    user: user,
    plantCount: plants.length,
    archivedCount: archived.length,
    careEventCount: events.length,
    careEventsThisMonth: eventsThisMonth,
    daysInApp: daysInApp,
    streakDays: streak,
    unlockedCodes: unlocked.map((e) => e.achievementCode).toSet(),
    recentXp: xpHistory.take(10).toList(),
  );
});

/// Считает дни подряд, в которые было хотя бы одно событие ухода.
///
/// Streak начинается с сегодня или вчера. Если сегодня события ещё
/// не было, но было вчера — streak не сбрасывается.
int _calculateStreak(List<CareEvent> events, DateTime now) {
  if (events.isEmpty) return 0;

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final days =
      events
          .map(
            (e) => DateTime(
              e.performedAt.year,
              e.performedAt.month,
              e.performedAt.day,
            ),
          )
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

  // Если ни сегодня, ни вчера — streak = 0.
  if (days.first != today && days.first != yesterday) return 0;

  var streak = 0;
  var expected = days.first;
  for (final day in days) {
    if (day == expected) {
      streak++;
      expected = expected.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}

final levelProgressProvider = Provider<double>((ref) {
  final data = ref.watch(profileDataProvider).asData?.value;
  if (data == null) return 0;
  final service = ref.watch(gamificationServiceProvider);
  return service.progressToNextLevel(xp: data.user.xp, level: data.user.level);
});

final xpForNextLevelProvider = Provider<int>((ref) {
  final data = ref.watch(profileDataProvider).asData?.value;
  if (data == null) return 100;
  final service = ref.watch(gamificationServiceProvider);
  return service.xpForNextLevel(data.user.level);
});

/// Список всех достижений (каталог + статус).
class AchievementView {
  const AchievementView({required this.def, required this.unlocked});

  final AchievementDef def;
  final bool unlocked;
}

final achievementsViewProvider = Provider<List<AchievementView>>((ref) {
  final data = ref.watch(profileDataProvider).asData?.value;
  final unlocked = data?.unlockedCodes ?? {};
  return AchievementsCatalog.all
      .map((d) => AchievementView(def: d, unlocked: unlocked.contains(d.code)))
      .toList();
});

// =========================================================================
//  Контроллер профиля
// =========================================================================

final userProfileControllerProvider = Provider<UserProfileController>((ref) {
  return UserProfileController(ref);
});

class UserProfileController {
  UserProfileController(this._ref);

  final Ref _ref;

  /// Обновляет имя.
  Future<void> updateName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final userId = _ref.read(currentUserIdProvider);
    final db = _ref.read(databaseProvider);
    await db.userDao.updateProfileFields(userId, displayName: Value(trimmed));
    _ref.invalidate(profileDataProvider);
  }

  /// Обновляет город.
  Future<void> updateCity(String? city) async {
    final userId = _ref.read(currentUserIdProvider);
    final db = _ref.read(databaseProvider);
    final trimmed = city?.trim();
    await db.userDao.updateProfileFields(
      userId,
      city: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
    );
    _ref.invalidate(profileDataProvider);
  }

  /// Обновляет описание «о себе».
  Future<void> updateBio(String? bio) async {
    final userId = _ref.read(currentUserIdProvider);
    final db = _ref.read(databaseProvider);
    final trimmed = bio?.trim();
    await db.userDao.updateProfileFields(
      userId,
      bio: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
    );
    _ref.invalidate(profileDataProvider);
  }

  /// Сохраняет новый аватар. Старый файл удаляется.
  Future<void> setAvatar(File file) async {
    final userId = _ref.read(currentUserIdProvider);
    final db = _ref.read(databaseProvider);
    final storage = _ref.read(imageStorageServiceProvider);

    final current = await db.userDao.getUserById(userId);
    final oldPath = current?.avatarPath;
    if (oldPath != null && oldPath.isNotEmpty) {
      await storage.deleteImage(oldPath);
    }

    final path = await storage.saveImage(file, prefix: 'avatar');
    await db.userDao.updateAvatarPath(userId, path);
    _ref.invalidate(profileDataProvider);
  }

  /// Удаляет аватар (возвращает инициалы).
  Future<void> clearAvatar() async {
    final userId = _ref.read(currentUserIdProvider);
    final db = _ref.read(databaseProvider);
    final storage = _ref.read(imageStorageServiceProvider);

    final current = await db.userDao.getUserById(userId);
    final oldPath = current?.avatarPath;
    if (oldPath != null && oldPath.isNotEmpty) {
      await storage.deleteImage(oldPath);
    }
    await db.userDao.updateAvatarPath(userId, null);
    _ref.invalidate(profileDataProvider);
  }

  /// Очищает журнал событий ухода. Растения остаются нетронутыми.
  Future<void> clearCareHistory() async {
    final db = _ref.read(databaseProvider);
    await db.delete(db.careEvents).go();
    _invalidateAll();
  }

  /// Удаляет все архивные растения.
  Future<int> deleteArchivedPlants() async {
    final userId = _ref.read(currentUserIdProvider);
    final repo = _ref.read(plantRepositoryProvider);
    final db = _ref.read(databaseProvider);

    final archived = await repo.getArchivedByUser(userId);
    for (final p in archived) {
      await db.deletePlantCascade(p.id);
    }

    _invalidateAll();
    _ref.invalidate(archivedPlantsProvider);
    return archived.length;
  }

  /// Полный сброс данных пользователя. Профиль сохраняется,
  /// прогресс, растения, диагнозы и журнал — удаляются.
  Future<void> fullReset() async {
    final userId = _ref.read(currentUserIdProvider);
    final db = _ref.read(databaseProvider);
    await db.resetUserData(userId);
    _invalidateAll();
    _ref.invalidate(archivedPlantsProvider);
    _ref.invalidate(userPlantsProvider);
  }

  void _invalidateAll() {
    _ref.invalidate(profileDataProvider);
    _ref.invalidate(userPlantsProvider);
    _ref.invalidate(plantsDueForWateringProvider);
    _ref.invalidate(plantsNeedingRepottingProvider);
  }
}
