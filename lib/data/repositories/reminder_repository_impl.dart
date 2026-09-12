import '../../core/database/database.dart';
import '../../domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Reminder>> getActive() => _db.reminderDao.getActive();

  @override
  Future<List<Reminder>> getByPlant(int plantId) =>
      _db.reminderDao.getByPlant(plantId);

  @override
  Future<List<Reminder>> getDueUntil(DateTime until) =>
      _db.reminderDao.getDueUntil(until);

  @override
  Future<int> create(RemindersCompanion reminder) =>
      _db.reminderDao.insertReminder(reminder);

  @override
  Future<void> deactivate(int id) => _db.reminderDao.deactivate(id);

  @override
  Future<void> delete(int id) => _db.reminderDao.deleteReminder(id);
}
