import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';

/// Провайдер базы данных (singleton на всё приложение).
/// В тестах его можно переопределить через overrideWithValue.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
