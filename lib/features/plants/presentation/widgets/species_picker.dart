import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../providers/plant_providers.dart';

/// Модальное окно выбора вида растения из справочника.
///
/// Возвращает выбранный [PlantSpecy] или null, если пользователь закрыл окно.
Future<PlantSpecy?> showSpeciesPicker(
  BuildContext context, {
  bool allowManualInput = true,
}) {
  return showModalBottomSheet<PlantSpecy>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _SpeciesPickerSheet(),
  );
}

class _SpeciesPickerSheet extends ConsumerStatefulWidget {
  const _SpeciesPickerSheet();

  @override
  ConsumerState<_SpeciesPickerSheet> createState() =>
      _SpeciesPickerSheetState();
}

class _SpeciesPickerSheetState extends ConsumerState<_SpeciesPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speciesAsync = ref.watch(allSpeciesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Выберите вид растения',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск по названию',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: speciesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Ошибка: $err')),
                data: (all) {
                  final filtered = _query.isEmpty
                      ? all
                      : all
                            .where(
                              (s) =>
                                  s.commonName.toLowerCase().contains(
                                    _query.toLowerCase(),
                                  ) ||
                                  s.scientificName.toLowerCase().contains(
                                    _query.toLowerCase(),
                                  ),
                            )
                            .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Ничего не найдено'),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final s = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.local_florist,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(s.commonName),
                        subtitle: Text(
                          s.scientificName,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        trailing: s.isPremium
                            ? const Icon(Icons.star, color: Colors.amber)
                            : null,
                        onTap: () => Navigator.of(context).pop(s),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
