import '../../core/database/database.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getActive();
  Future<List<Reminder>> getByPlant(int plantId);
  Future<List<Reminder>> getDueUntil(DateTime until);
  Future<int> create(RemindersCompanion reminder);
  Future<void> deactivate(int id);
  Future<void> delete(int id);
}
