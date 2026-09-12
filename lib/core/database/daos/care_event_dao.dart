import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'care_event_dao.g.dart';

@DriftAccessor(tables: [CareEvents])
class CareEventDao extends DatabaseAccessor<AppDatabase>
    with _$CareEventDaoMixin {
  CareEventDao(super.db);

  Future<List<CareEvent>> getByPlant(int plantId) =>
      (select(careEvents)
            ..where((t) => t.plantId.equals(plantId))
            ..orderBy([(t) => OrderingTerm.desc(t.performedAt)]))
          .get();

  Future<List<CareEvent>> getByPlantInRange(
    int plantId,
    DateTime from,
    DateTime to,
  ) =>
      (select(careEvents)
            ..where(
              (t) =>
                  t.plantId.equals(plantId) &
                  t.performedAt.isBiggerOrEqualValue(from) &
                  t.performedAt.isSmallerOrEqualValue(to),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.performedAt)]))
          .get();

  Future<List<CareEvent>> getRecent(int limit) =>
      (select(careEvents)
            ..orderBy([(t) => OrderingTerm.desc(t.performedAt)])
            ..limit(limit))
          .get();

  /// Все события в диапазоне (для календаря).
  Future<List<CareEvent>> getInRange(DateTime from, DateTime to) =>
      (select(careEvents)
            ..where(
              (t) =>
                  t.performedAt.isBiggerOrEqualValue(from) &
                  t.performedAt.isSmallerOrEqualValue(to),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.performedAt)]))
          .get();

  Future<int> insertEvent(CareEventsCompanion event) =>
      into(careEvents).insert(event);

  Future<int> deleteEvent(int id) =>
      (delete(careEvents)..where((t) => t.id.equals(id))).go();

  Future<int> countByType(String type) => (select(
    careEvents,
  )..where((t) => t.type.equals(type))).get().then((rows) => rows.length);
}
