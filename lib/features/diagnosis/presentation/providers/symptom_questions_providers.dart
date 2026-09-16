import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Один блок наводящих вопросов.
class SymptomQuestionBlock {
  const SymptomQuestionBlock({
    required this.title,
    required this.hint,
    required this.questions,
  });

  final String title;
  final String hint;
  final List<SymptomQuestion> questions;
}

class SymptomQuestion {
  const SymptomQuestion({required this.label, required this.keywords});

  final String label;
  final String keywords;
}

/// Загрузка вопросов из ассета. Один раз на приложение.
final symptomQuestionsProvider = FutureProvider<List<SymptomQuestionBlock>>((
  ref,
) async {
  final raw = await rootBundle.loadString('assets/data/symptom_questions.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((item) {
        final m = item as Map<String, dynamic>;
        final qs = (m['questions'] as List)
            .map(
              (q) => SymptomQuestion(
                label: (q as Map<String, dynamic>)['label'] as String,
                keywords: q['keywords'] as String,
              ),
            )
            .toList(growable: false);
        return SymptomQuestionBlock(
          title: m['title'] as String,
          hint: m['hint'] as String,
          questions: qs,
        );
      })
      .toList(growable: false);
});
