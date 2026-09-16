import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../providers/plant_providers.dart';
import '../providers/plants_filter_providers.dart';
import '../widgets/plant_card.dart';

class PlantsListScreen extends ConsumerStatefulWidget {
  const PlantsListScreen({super.key});

  @override
  ConsumerState<PlantsListScreen> createState() => _PlantsListScreenState();
}

class _PlantsListScreenState extends ConsumerState<PlantsListScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _searchFocus.requestFocus(),
      );
    } else {
      _searchController.clear();
      ref.read(plantsFilterProvider.notifier).setQuery('');
    }
  }

  void _resetFilters() {
    _searchController.clear();
    ref.read(plantsFilterProvider.notifier).reset();
    if (_searchOpen) setState(() => _searchOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(filteredPlantsProvider);
    final filterState = ref.watch(plantsFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: _searchOpen
            ? _SearchField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: (v) =>
                    ref.read(plantsFilterProvider.notifier).setQuery(v),
                onClose: _toggleSearch,
              )
            : const Text('Мои растения'),
        actions: _searchOpen
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Поиск',
                  onPressed: _toggleSearch,
                ),
                _SortMenu(
                  current: filterState.sort,
                  onSelected: (s) =>
                      ref.read(plantsFilterProvider.notifier).setSort(s),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Обновить',
                  onPressed: () {
                    ref.invalidate(userPlantsProvider);
                    ref.invalidate(archivedPlantsProvider);
                  },
                ),
              ],
      ),
      body: Column(
        children: [
          _FilterChips(
            current: filterState.filter,
            onSelected: (f) =>
                ref.read(plantsFilterProvider.notifier).setFilter(f),
          ),
          if (!filterState.isDefault) _ResetBar(onReset: _resetFilters),
          const Divider(height: 1),
          Expanded(
            child: dataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => _ErrorView(
                message: err.toString(),
                onRetry: () {
                  ref.invalidate(userPlantsProvider);
                  ref.invalidate(archivedPlantsProvider);
                },
              ),
              data: (data) {
                if (!data.hasAnyPlants) {
                  return _EmptyView(onAdd: () => context.push('/plants/new'));
                }
                if (data.plants.isEmpty) {
                  return _NoMatchesView(onReset: _resetFilters);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(userPlantsProvider);
                    ref.invalidate(archivedPlantsProvider);
                    await ref.read(filteredPlantsProvider.future);
                  },
                  child: _buildList(data),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/plants/new'),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  Widget _buildList(PlantsListData data) {
    final diagnosed = data.diagnosedPlantIds;

    if (!data.grouped) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: data.plants.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final plant = data.plants[i];
          return _PlantRow(
            plant: plant,
            hasDiagnosis: diagnosed.contains(plant.id),
            onTap: () => context.push('/plants/${plant.id}'),
          );
        },
      );
    }

    // Группированный режим — по видам или по буквам.
    final children = <Widget>[];
    for (final group in data.groups) {
      children.add(_GroupHeader(group: group));
      if (group.isLetter) {
        // Для алфавитных групп — плотный список без отступов.
        for (final plant in group.plants) {
          children.add(
            _PlantRow(
              plant: plant,
              hasDiagnosis: diagnosed.contains(plant.id),
              onTap: () => context.push('/plants/${plant.id}'),
            ),
          );
        }
        children.add(const SizedBox(height: 4));
      } else {
        // Для групп по видам — карточки с отступами.
        children.add(const SizedBox(height: 8));
        for (final plant in group.plants) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PlantRow(
                plant: plant,
                hasDiagnosis: diagnosed.contains(plant.id),
                onTap: () => context.push('/plants/${plant.id}'),
              ),
            ),
          );
        }
        children.add(const SizedBox(height: 8));
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: children,
    );
  }
}

/// Заголовок группы — буква или название вида.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final PlantGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Алфавитная группа — компактная цветная полоса.
    if (group.isLetter) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              group.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${group.count}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Группа по виду — крупный заголовок с научным названием.
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (group.scientificName != null &&
                    group.scientificName!.isNotEmpty)
                  Text(
                    group.scientificName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${group.count}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Имя, вид или место',
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Закрыть',
          onPressed: onClose,
        ),
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.current, required this.onSelected});

  final PlantSortType current;
  final ValueChanged<PlantSortType> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PlantSortType>(
      icon: const Icon(Icons.sort),
      tooltip: 'Сортировка',
      initialValue: current,
      onSelected: onSelected,
      itemBuilder: (context) => PlantSortType.values
          .map(
            (s) => PopupMenuItem<PlantSortType>(
              value: s,
              child: Row(
                children: [
                  Icon(
                    s == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 20,
                    color: s == current
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 12),
                  Text(s.label),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.current, required this.onSelected});

  final PlantFilterType current;
  final ValueChanged<PlantFilterType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: PlantFilterType.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = PlantFilterType.values[i];
          return ChoiceChip(
            label: Text(f.label),
            selected: f == current,
            onSelected: (_) => onSelected(f),
          );
        },
      ),
    );
  }
}

class _ResetBar extends StatelessWidget {
  const _ResetBar({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Активны фильтры',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: onReset,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}

class _PlantRow extends StatelessWidget {
  const _PlantRow({
    required this.plant,
    required this.hasDiagnosis,
    required this.onTap,
  });

  final Plant plant;
  final bool hasDiagnosis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!hasDiagnosis) {
      return PlantCard(plant: plant, onTap: onTap);
    }
    return Stack(
      children: [
        PlantCard(plant: plant, onTap: onTap),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.healing, size: 12, color: Colors.red.shade700),
                const SizedBox(width: 4),
                Text(
                  'лечение',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_florist_outlined,
              size: 96,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Пока нет растений',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте первое растение, чтобы начать\nследить за его уходом',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Добавить растение'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchesView extends StatelessWidget {
  const _NoMatchesView({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 72,
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить запрос или сбросить фильтры',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: onReset,
              icon: const Icon(Icons.clear_all),
              label: const Text('Сбросить фильтры'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Ошибка: $message', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
