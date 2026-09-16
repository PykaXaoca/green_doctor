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

  // =========================================================================
  //  Отмена событий ухода
  // =========================================================================

  /// Одно событие по id.
  Future<CareEvent?> getById(int id) =>
      (select(careEvents)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Последнее событие указанного типа для растения до момента [before].
  ///
  /// Если [before] не задан — берётся последнее событие вообще.
  /// Используется после удаления события, чтобы пересчитать
  /// `lastWateredAt` / `lastFertilizedAt` у растения.
  Future<CareEvent?> getLastByPlantAndType(
    int plantId,
    String type, {
    DateTime? before,
  }) {
    final query = select(careEvents)
      ..where((t) => t.plantId.equals(plantId) & t.type.equals(type));
    if (before != null) {
      query.where((t) => t.performedAt.isSmallerThanValue(before));
    }
    query
      ..orderBy([(t) => OrderingTerm.desc(t.performedAt)])
      ..limit(1);
    return query.getSingleOrNull();
  }
}
