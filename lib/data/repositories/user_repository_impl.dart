import '../../core/database/database.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<AppUser>> getAll() => _db.userDao.getAllUsers();

  @override
  Future<AppUser?> getById(int id) => _db.userDao.getUserById(id);

  @override
  Future<int> create(AppUsersCompanion user) => _db.userDao.insertUser(user);

  @override
  Future<bool> update(AppUser user) => _db.userDao.updateUser(user);

  @override
  Future<void> delete(int id) => _db.userDao.deleteUser(id);

  @override
  Future<void> addXpEvent(UserXpEventsCompanion event) =>
      _db.userDao.addXpEvent(event);

  @override
  Future<List<UserXpEvent>> getXpHistory(int userId) =>
      _db.userDao.getXpHistory(userId);

  @override
  Future<void> unlockAchievement(UserAchievementsCompanion ua) =>
      _db.userDao.unlockAchievement(ua);

  @override
  Future<List<UserAchievement>> getUserAchievements(int userId) =>
      _db.userDao.getUserAchievements(userId);
}
