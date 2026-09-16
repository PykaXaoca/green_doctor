import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../diagnosis/presentation/providers/diagnosis_providers.dart';
import 'plant_providers.dart';

/// Фильтр по статусу растения.
enum PlantFilterType {
  all('Все'),
  needWatering('Пора полить'),
  overdueWatering('Просрочен'),
  hasDiagnoses('С диагнозом'),
  archived('В архиве');

  const PlantFilterType(this.label);
  final String label;
}

/// Сортировка списка растений.
enum PlantSortType {
  bySpecies('По видам'),
  alphabetical('По имени'),
  addedDate('По дате добавления'),
  urgency('По срочности полива');

  const PlantSortType(this.label);
  final String label;
}

/// Состояние фильтра и поиска.
class PlantsFilterState {
  const PlantsFilterState({
    this.query = '',
    this.filter = PlantFilterType.all,
    this.sort = PlantSortType.bySpecies,
  });

  final String query;
  final PlantFilterType filter;
  final PlantSortType sort;

  bool get isDefault =>
      query.isEmpty &&
      filter == PlantFilterType.all &&
      sort == PlantSortType.bySpecies;

  PlantsFilterState copyWith({
    String? query,
    PlantFilterType? filter,
    PlantSortType? sort,
  }) {
    return PlantsFilterState(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
    );
  }
}

class PlantsFilterNotifier extends Notifier<PlantsFilterState> {
  @override
  PlantsFilterState build() => const PlantsFilterState();

  void setQuery(String value) => state = state.copyWith(query: value);
  void setFilter(PlantFilterType filter) =>
      state = state.copyWith(filter: filter);
  void setSort(PlantSortType sort) => state = state.copyWith(sort: sort);
  void reset() => state = const PlantsFilterState();
}

final plantsFilterProvider =
    NotifierProvider<PlantsFilterNotifier, PlantsFilterState>(
      PlantsFilterNotifier.new,
    );

/// Группа растений.
///
/// Используется в двух режимах:
///  * **по видам** — `isLetter == false`, [speciesId] и [scientificName]
///    заполнены, [title] — народное название вида;
///  * **по буквам** — `isLetter == true`, [title] — буква («А», «Б»…, «#»),
///    остальные поля null.
class PlantGroup {
  const PlantGroup({
    required this.speciesId,
    required this.title,
    required this.plants,
    this.scientificName,
    this.isLetter = false,
  });

  final String? speciesId;
  final String title;
  final String? scientificName;
  final List<Plant> plants;
  final bool isLetter;

  int get count => plants.length;
}

/// Результат фильтрации: сами растения + метаданные для UI.
class PlantsListData {
  const PlantsListData({
    required this.plants,
    required this.groups,
    required this.totalCount,
    required this.diagnosedPlantIds,
    required this.grouped,
  });

  final List<Plant> plants;
  final List<PlantGroup> groups;
  final int totalCount;
  final Set<int> diagnosedPlantIds;
  final bool grouped;

  bool get hasAnyPlants => totalCount > 0;
  bool get isFilteredEmpty => totalCount > 0 && plants.isEmpty;
}

/// Отфильтрованный и отсортированный список растений.
final filteredPlantsProvider = FutureProvider<PlantsListData>((ref) async {
  final filterState = ref.watch(plantsFilterProvider);
  final isArchivedMode = filterState.filter == PlantFilterType.archived;

  final plants = isArchivedMode
      ? await ref.watch(archivedPlantsProvider.future)
      : await ref.watch(userPlantsProvider.future);

  final activeDiagnoses = await ref.watch(activeDiagnosesProvider.future);
  final diagnosedPlantIds = <int>{};
  for (final d in activeDiagnoses) {
    final pid = d.plantId;
    if (pid != null) diagnosedPlantIds.add(pid);
  }

  if (plants.isEmpty) {
    return PlantsListData(
      plants: const [],
      groups: const [],
      totalCount: 0,
      diagnosedPlantIds: diagnosedPlantIds,
      grouped: false,
    );
  }

  final scheduler = ref.read(careSchedulerProvider);
  final speciesRepo = ref.read(speciesRepositoryProvider);
  final allSpecies = await speciesRepo.getAll();
  final speciesById = {for (final s in allSpecies) s.id: s};

  // --- 1. Поиск ---
  final q = filterState.query.trim().toLowerCase();

  // --- 2. Фильтр ---
  final filtered = plants.where((p) {
    if (q.isNotEmpty) {
      final nameMatch = p.customName.toLowerCase().contains(q);
      final locationMatch = (p.location ?? '').toLowerCase().contains(q);

      var speciesMatch = false;
      if (p.speciesId != null) {
        final species = speciesById[p.speciesId];
        if (species != null) {
          speciesMatch =
              species.commonName.toLowerCase().contains(q) ||
              species.scientificName.toLowerCase().contains(q);
        }
      }

      if (!nameMatch && !locationMatch && !speciesMatch) return false;
    }

    switch (filterState.filter) {
      case PlantFilterType.all:
      case PlantFilterType.archived:
        break;
      case PlantFilterType.needWatering:
        if (!scheduler.isWateringDue(p)) return false;
        break;
      case PlantFilterType.overdueWatering:
        if (!scheduler.isWateringOverdue(p)) return false;
        break;
      case PlantFilterType.hasDiagnoses:
        if (!diagnosedPlantIds.contains(p.id)) return false;
        break;
    }

    return true;
  }).toList();

  // --- 3. Сортировка ---
  switch (filterState.sort) {
    case PlantSortType.bySpecies:
    case PlantSortType.alphabetical:
      filtered.sort(
        (a, b) =>
            a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
      );
      break;
    case PlantSortType.addedDate:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case PlantSortType.urgency:
      filtered.sort((a, b) {
        final ad = a.nextWaterDue;
        final bd = b.nextWaterDue;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });
      break;
  }

  // --- 4. Группировка ---
  final List<PlantGroup> groups;
  switch (filterState.sort) {
    case PlantSortType.bySpecies:
      groups = _groupBySpecies(filtered, speciesById);
      break;
    case PlantSortType.alphabetical:
      groups = _groupByLetter(filtered);
      break;
    case PlantSortType.addedDate:
    case PlantSortType.urgency:
      groups = const [];
      break;
  }

  return PlantsListData(
    plants: filtered,
    groups: groups,
    totalCount: plants.length,
    diagnosedPlantIds: diagnosedPlantIds,
    grouped: groups.isNotEmpty,
  );
});

/// Разбить растения по видам. Внутри группы — по имени.
/// Растения без вида — в группу «Без вида» в конце.
List<PlantGroup> _groupBySpecies(
  List<Plant> plants,
  Map<String, PlantSpecy> speciesById,
) {
  final bySpecies = <String?, List<Plant>>{};
  for (final p in plants) {
    bySpecies.putIfAbsent(p.speciesId, () => <Plant>[]).add(p);
  }

  final groups = <PlantGroup>[];
  for (final entry in bySpecies.entries) {
    final speciesId = entry.key;
    final list = entry.value
      ..sort(
        (a, b) =>
            a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
      );

    if (speciesId == null) continue;

    final species = speciesById[speciesId];
    groups.add(
      PlantGroup(
        speciesId: speciesId,
        title: species?.commonName ?? speciesId,
        scientificName: species?.scientificName,
        plants: list,
      ),
    );
  }

  groups.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

  final withoutSpecies = bySpecies[null];
  if (withoutSpecies != null && withoutSpecies.isNotEmpty) {
    groups.add(
      PlantGroup(speciesId: null, title: 'Без вида', plants: withoutSpecies),
    );
  }

  return groups;
}

/// Разбить растения по первой букве имени.
///
/// Порядок: сначала русские/латинские буквы по алфавиту, потом «#»
/// (для имён, начинающихся с цифры или другого символа).
List<PlantGroup> _groupByLetter(List<Plant> plants) {
  final byLetter = <String, List<Plant>>{};
  for (final p in plants) {
    final letter = _firstLetter(p.customName);
    byLetter.putIfAbsent(letter, () => <Plant>[]).add(p);
  }

  final letters = byLetter.keys.toList()
    ..sort((a, b) {
      if (a == '#') return 1;
      if (b == '#') return -1;
      return a.compareTo(b);
    });

  return letters.map((letter) {
    final list = byLetter[letter]!
      ..sort(
        (a, b) =>
            a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
      );
    return PlantGroup(
      speciesId: null,
      title: letter,
      plants: list,
      isLetter: true,
    );
  }).toList();
}

/// Первая буква имени в верхнем регистре. Если символ не буква — «#».
String _firstLetter(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '#';
  final ch = trimmed[0].toUpperCase();
  if (RegExp(r'[А-ЯЁA-Z]').hasMatch(ch)) return ch;
  return '#';
}
