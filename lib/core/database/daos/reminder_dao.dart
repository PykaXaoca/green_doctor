import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Future<List<Reminder>> getActive() =>
      (select(reminders)..where((t) => t.isActive.equals(true))).get();

  Future<List<Reminder>> getByPlant(int plantId) =>
      (select(reminders)..where((t) => t.plantId.equals(plantId))).get();

  Future<List<Reminder>> getDueUntil(DateTime until) =>
      (select(reminders)..where(
            (t) =>
                t.isActive.equals(true) & t.dueAt.isSmallerOrEqualValue(until),
          ))
          .get();

  Future<int> insertReminder(RemindersCompanion r) => into(reminders).insert(r);

  Future<int> deactivate(int id) =>
      (update(reminders)..where((t) => t.id.equals(id))).write(
        const RemindersCompanion(isActive: Value(false)),
      );

  Future<int> deleteReminder(int id) =>
      (delete(reminders)..where((t) => t.id.equals(id))).go();
}
