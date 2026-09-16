import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../core/services/symptom_matcher.dart';

/// Матчер по запросу. Пересчитывается при смене текста.
///
/// Возвращает `null`, если запрос пустой.
final symptomMatchProvider = FutureProvider.family<List<SymptomMatch>, String>((
  ref,
  query,
) async {
  if (query.trim().isEmpty) return const [];

  final db = ref.watch(databaseProvider);
  final diseases = await db.diseaseDao.getAll();
  if (diseases.isEmpty) return const [];

  return SymptomMatcher.match(
    query: query,
    diseases: diseases,
    topN: 5,
    threshold: 0.15,
  );
});
