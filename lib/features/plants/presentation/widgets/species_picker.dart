import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../providers/plant_providers.dart';

/// Модальное окно выбора вида растения из справочника.
///
/// Список отсортирован по алфавиту и разбит на секции по первой букве
/// (русский алфавит). Если название начинается не с буквы — попадает
/// в секцию «#».
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
                  final filtered = _filterAndSort(all);
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Ничего не найдено'),
                      ),
                    );
                  }
                  return _buildGroupedList(filtered, scrollController);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Фильтрует по поисковому запросу и сортирует по русскому алфавиту.
  List<PlantSpecy> _filterAndSort(List<PlantSpecy> all) {
    final q = _query.toLowerCase();
    final list = q.isEmpty
        ? List<PlantSpecy>.from(all)
        : all
              .where(
                (s) =>
                    s.commonName.toLowerCase().contains(q) ||
                    s.scientificName.toLowerCase().contains(q),
              )
              .toList();
    list.sort(
      (a, b) =>
          a.commonName.toLowerCase().compareTo(b.commonName.toLowerCase()),
    );
    return list;
  }

  /// Строит список с заголовками по первой букве.
  Widget _buildGroupedList(
    List<PlantSpecy> species,
    ScrollController controller,
  ) {
    // Группируем по первой букве.
    final groups = <String, List<PlantSpecy>>{};
    for (final s in species) {
      final letter = _firstLetter(s.commonName);
      groups.putIfAbsent(letter, () => <PlantSpecy>[]).add(s);
    }

    // Сортируем буквы: сначала русские по алфавиту, потом «#».
    final letters = groups.keys.toList()
      ..sort((a, b) {
        if (a == '#') return 1;
        if (b == '#') return -1;
        return a.compareTo(b);
      });

    final children = <Widget>[];
    for (final letter in letters) {
      children.add(_LetterHeader(letter: letter));
      for (final s in groups[letter]!) {
        children.add(_SpeciesTile(species: s));
      }
    }

    return ListView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 16),
      children: children,
    );
  }

  /// Возвращает первую букву названия в верхнем регистре.
  /// Если это не буква — «#».
  String _firstLetter(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '#';
    final ch = trimmed[0].toUpperCase();
    // Русские буквы и латиница.
    if (RegExp(r'[А-ЯЁA-Z]').hasMatch(ch)) return ch;
    return '#';
  }
}

/// Заголовок секции с буквой.
class _LetterHeader extends StatelessWidget {
  const _LetterHeader({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        letter,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Плитка одного вида растения.
class _SpeciesTile extends StatelessWidget {
  const _SpeciesTile({required this.species});

  final PlantSpecy species;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.local_florist,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(species.commonName),
      subtitle: Text(
        species.scientificName,
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      trailing: species.isPremium
          ? const Icon(Icons.star, color: Colors.amber)
          : null,
      onTap: () => Navigator.of(context).pop(species),
    );
  }
}
