import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../providers/diagnosis_providers.dart';

/// Диалог выбора болезни вручную.
///
/// Возвращает выбранную болезнь или `null`.
Future<PlantDisease?> showManualDiseasePicker(BuildContext context) {
  return showModalBottomSheet<PlantDisease>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _ManualDiseasePickerSheet(),
  );
}

class _ManualDiseasePickerSheet extends ConsumerStatefulWidget {
  const _ManualDiseasePickerSheet();

  @override
  ConsumerState<_ManualDiseasePickerSheet> createState() =>
      _ManualDiseasePickerSheetState();
}

class _ManualDiseasePickerSheetState
    extends ConsumerState<_ManualDiseasePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diseasesAsync = ref.watch(allDiseasesProvider);

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
                'Выберите болезнь',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
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
              child: diseasesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Ошибка: $err')),
                data: (all) {
                  final q = _query.toLowerCase();
                  final filtered = q.isEmpty
                      ? all
                      : all
                            .where(
                              (d) =>
                                  d.name.toLowerCase().contains(q) ||
                                  (d.description ?? '').toLowerCase().contains(
                                    q,
                                  ),
                            )
                            .toList();

                  filtered.sort(
                    (a, b) =>
                        a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                  );

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
                    itemBuilder: (context, i) {
                      final d = filtered[i];
                      return ListTile(
                        leading: const Icon(
                          Icons.coronavirus_outlined,
                          color: Colors.redAccent,
                        ),
                        title: Text(d.name),
                        subtitle:
                            d.description != null && d.description!.isNotEmpty
                            ? Text(
                                d.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(d),
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
