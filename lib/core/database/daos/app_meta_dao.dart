import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'app_meta_dao.g.dart';

@DriftAccessor(tables: [AppMeta])
class AppMetaDao extends DatabaseAccessor<AppDatabase> with _$AppMetaDaoMixin {
  AppMetaDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(
      appMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String key, String value) =>
      into(appMeta).insertOnConflictUpdate(
        AppMetaCompanion(key: Value(key), value: Value(value)),
      );

  Future<void> deleteKey(String key) =>
      (delete(appMeta)..where((t) => t.key.equals(key))).go();
}
