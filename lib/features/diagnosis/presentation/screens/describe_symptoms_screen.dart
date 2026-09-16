import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/symptom_matcher.dart';
import '../../../../core/utils/snack_bars.dart';
import '../../../plants/presentation/providers/plant_providers.dart';
import '../providers/diagnosis_providers.dart';
import '../providers/symptom_match_providers.dart';
import '../providers/symptom_questions_providers.dart';
import '../widgets/symptom_match_card.dart';

/// Экран описания симптомов.
class DescribeSymptomsScreen extends ConsumerStatefulWidget {
  const DescribeSymptomsScreen({super.key, required this.plantId});

  final int? plantId;

  @override
  ConsumerState<DescribeSymptomsScreen> createState() =>
      _DescribeSymptomsScreenState();
}

class _DescribeSymptomsScreenState
    extends ConsumerState<DescribeSymptomsScreen> {
  final _controller = TextEditingController();
  final _selectedQuestions = <String>{};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _effectiveQuery {
    final parts = <String>[];
    final text = _controller.text.trim();
    if (text.isNotEmpty) parts.add(text);

    final questionsAsync = ref.read(symptomQuestionsProvider);
    final blocks = questionsAsync.asData?.value ?? const [];
    for (final block in blocks) {
      for (final q in block.questions) {
        if (_selectedQuestions.contains(q.label)) {
          parts.add(q.keywords);
        }
      }
    }
    return parts.join(' ');
  }

  void _toggleQuestion(String label) {
    setState(() {
      if (_selectedQuestions.contains(label)) {
        _selectedQuestions.remove(label);
      } else {
        _selectedQuestions.add(label);
      }
    });
  }

  void _clear() {
    setState(() {
      _controller.clear();
      _selectedQuestions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _effectiveQuery;
    final matchAsync = ref.watch(symptomMatchProvider(query));
    final questionsAsync = ref.watch(symptomQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Описать симптомы'),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Очистить',
              onPressed: _clear,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Опишите своими словами, что видите на растении. '
            'Можно отметить готовые варианты — это уточнит результат.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText:
                  'Например: на листьях белый налёт, '
                  'листья желтеют, появилось после полива',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 20),

          questionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Ошибка: $err'),
            data: (blocks) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final block in blocks) ...[
                  _QuestionBlock(
                    block: block,
                    selected: _selectedQuestions,
                    onToggle: _toggleQuestion,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          if (query.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.search, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Подходящие болезни', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            matchAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Ошибка: $err'),
              data: (matches) {
                if (matches.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'По этому описанию ничего не нашлось. '
                              'Попробуйте добавить детали или '
                              'отметить подсказки.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: matches
                      .map(
                        (m) => SymptomMatchCard(
                          match: m,
                          onTap: () => _showDiseasePreview(m),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ] else
            Card(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Опишите проблему или отметьте подсказки — '
                        'здесь появятся вероятные болезни.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showDiseasePreview(SymptomMatch match) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DiseasePreviewDialog(match: match),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    try {
      final userId = ref.read(currentUserIdProvider);
      final controller = ref.read(diagnosisControllerProvider);
      final id = await controller.startTreatment(
        diseaseId: match.disease.id,
        userId: userId,
        plantId: widget.plantId,
        confidence: match.score,
      );

      if (!mounted) return;

      // Сначала показываем SnackBar, потом закрываем экран.
      // Кнопка «Открыть» использует GoRouter, захваченный в момент
      // показа — он остаётся валидным после pop().
      showAppSnackBar(
        context,
        'Лечение начато: ${match.disease.name}',
        actionLabel: 'Открыть',
        actionRoute: '/diagnosis/treatment/$id',
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Ошибка: $e');
    }
  }
}

class _QuestionBlock extends StatelessWidget {
  const _QuestionBlock({
    required this.block,
    required this.selected,
    required this.onToggle,
  });

  final SymptomQuestionBlock block;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          block.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          block.hint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: block.questions.map((q) {
            final isSelected = selected.contains(q.label);
            return FilterChip(
              label: Text(q.label),
              selected: isSelected,
              onSelected: (_) => onToggle(q.label),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DiseasePreviewDialog extends StatelessWidget {
  const _DiseasePreviewDialog({required this.match});

  final SymptomMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = match.disease;

    return AlertDialog(
      title: Text(d.name),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Совпадение: ${match.percent}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (d.description != null && d.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(d.description!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            Text(
              'Симптомы',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ..._parseSymptoms(d.symptomsJson).map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(s)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'При нажатии «Начать лечение» будет создан диагноз с '
              'планом шагов и напоминаниями.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Начать лечение'),
        ),
      ],
    );
  }

  List<String> _parseSymptoms(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList(growable: false);
      }
      return [decoded.toString()];
    } catch (_) {
      return const [];
    }
  }
}
