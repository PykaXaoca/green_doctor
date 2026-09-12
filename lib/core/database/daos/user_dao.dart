import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [AppUsers, UserAchievements, UserXpEvents])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<List<AppUser>> getAllUsers() => select(appUsers).get();

  Future<AppUser?> getUserById(int id) =>
      (select(appUsers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertUser(AppUsersCompanion user) => into(appUsers).insert(user);

  Future<bool> updateUser(AppUser user) => update(appUsers).replace(user);

  Future<int> deleteUser(int id) =>
      (delete(appUsers)..where((t) => t.id.equals(id))).go();

  Future<int> addXpEvent(UserXpEventsCompanion event) =>
      into(userXpEvents).insert(event);

  Future<List<UserXpEvent>> getXpHistory(int userId) =>
      (select(userXpEvents)..where((t) => t.userId.equals(userId))).get();

  Future<int> unlockAchievement(UserAchievementsCompanion ua) =>
      into(userAchievements).insert(ua);

  Future<List<UserAchievement>> getUserAchievements(int userId) =>
      (select(userAchievements)..where((t) => t.userId.equals(userId))).get();
}
