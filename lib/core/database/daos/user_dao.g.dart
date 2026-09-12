// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dao.dart';

// ignore_for_file: type=lint
mixin _$UserDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppUsersTable get appUsers => attachedDatabase.appUsers;
  $AchievementsTable get achievements => attachedDatabase.achievements;
  $UserAchievementsTable get userAchievements =>
      attachedDatabase.userAchievements;
  $UserXpEventsTable get userXpEvents => attachedDatabase.userXpEvents;
  UserDaoManager get managers => UserDaoManager(this);
}

class UserDaoManager {
  final _$UserDaoMixin _db;
  UserDaoManager(this._db);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db.attachedDatabase, _db.appUsers);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db.attachedDatabase, _db.achievements);
  $$UserAchievementsTableTableManager get userAchievements =>
      $$UserAchievementsTableTableManager(
        _db.attachedDatabase,
        _db.userAchievements,
      );
  $$UserXpEventsTableTableManager get userXpEvents =>
      $$UserXpEventsTableTableManager(_db.attachedDatabase, _db.userXpEvents);
}
