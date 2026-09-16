import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/snack_bars.dart';
import '../../../../domain/models/active_diagnosis.dart';
import '../../../diagnosis/presentation/providers/diagnosis_providers.dart';
import '../../../diagnosis/presentation/widgets/manual_disease_picker.dart';
import '../providers/plant_providers.dart';
import 'diagnosis_card.dart';

/// Секция «Здоровье» в карточке растения.
class HealthSection extends ConsumerWidget {
  const HealthSection({super.key, required this.plantId});

  final int plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(activeDiagnosesForPlantProvider(plantId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.healing, color: Colors.redAccent),
                const SizedBox(width: 8),
                const Text(
                  'Здоровье',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                healthAsync.maybeWhen(
                  data: (list) => list.isEmpty
                      ? const SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${list.length}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            healthAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Ошибка: $err'),
              data: (list) => _buildList(context, ref, list),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<ActiveDiagnosis> list,
  ) {
    if (list.isEmpty) {
      return _emptyState(context, ref);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...list.map((d) => DiagnosisCard(active: d)),
        const SizedBox(height: 12),
        _actionButtons(context, ref),
      ],
    );
  }

  Widget _emptyState(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Заметили пятна, налёт или вредителей? Выберите способ '
          'диагностики — мы подскажем вероятные болезни и план лечения.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        _actionButtons(context, ref),
      ],
    );
  }

  /// Три способа начать диагностику. Всегда вертикально, с полными
  /// подписями — форма не зависит от того, есть ли активные диагнозы.
  Widget _actionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => context.push('/diagnosis/plant/$plantId'),
          icon: const Icon(Icons.healing),
          label: const Text('Диагностировать по фото'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () => context.push('/diagnosis/describe/$plantId'),
          icon: const Icon(Icons.description_outlined),
          label: const Text('Описать симптомы'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _pickManual(context, ref),
          icon: const Icon(Icons.list_alt_outlined),
          label: const Text('Выбрать болезнь вручную'),
        ),
      ],
    );
  }

  Future<void> _pickManual(BuildContext context, WidgetRef ref) async {
    final disease = await showManualDiseasePicker(context);
    if (disease == null) return;
    if (!context.mounted) return;

    try {
      final userId = ref.read(currentUserIdProvider);
      final controller = ref.read(diagnosisControllerProvider);
      await controller.startTreatment(
        diseaseId: disease.id,
        userId: userId,
        plantId: plantId,
      );
      // Snackbar «Лечение начато» намеренно не показываем —
      // карточка болезни появится в блоке «Здоровье» автоматически
      // после инвалидации провайдера в контроллере.
    } catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, 'Ошибка: $e');
    }
  }
}
