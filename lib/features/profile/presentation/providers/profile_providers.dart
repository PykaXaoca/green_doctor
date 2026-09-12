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
    required this.careEventCount,
    required this.unlockedCodes,
    required this.recentXp,
  });

  final AppUser user;
  final int plantCount;
  final int careEventCount;
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
  final events = await careRepo.getRecent(10000);
  final unlocked = await userRepo.getUserAchievements(userId);
  final xpHistory = await db.userDao.getXpHistory(userId);
  xpHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return ProfileData(
    user: user!,
    plantCount: plants.length,
    careEventCount: events.length,
    unlockedCodes: unlocked.map((e) => e.achievementCode).toSet(),
    recentXp: xpHistory.take(10).toList(),
  );
});

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
