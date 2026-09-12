import '../../core/database/database.dart';

abstract class UserRepository {
  Future<List<AppUser>> getAll();
  Future<AppUser?> getById(int id);
  Future<int> create(AppUsersCompanion user);
  Future<bool> update(AppUser user);
  Future<void> delete(int id);
  Future<void> addXpEvent(UserXpEventsCompanion event);
  Future<List<UserXpEvent>> getXpHistory(int userId);
  Future<void> unlockAchievement(UserAchievementsCompanion ua);
  Future<List<UserAchievement>> getUserAchievements(int userId);
}
