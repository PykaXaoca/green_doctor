import 'dart:convert';

import '../database/database.dart';

/// Результат сопоставления симптомов.
class SymptomMatch {
  const SymptomMatch({
    required this.disease,
    required this.score,
    required this.matchedTokens,
    required this.totalTokens,
  });

  final PlantDisease disease;

  /// Доля совпавших токенов запроса. 0.0 – 1.0.
  final double score;

  /// Уникальные токены запроса, найденные в болезни.
  final List<String> matchedTokens;

  /// Сколько уникальных значимых токенов было в запросе.
  final int totalTokens;

  int get percent => (score * 100).round();
}

/// Локальный матчер симптомов — без ИИ.
///
/// Работает по принципу:
///  1. Токенизирует текст пользователя и корпус каждой болезни.
///  2. Приводит токены к нижнему регистру, удаляет стоп-слова.
///  3. Сравнивает по префиксу длиной ≥ [_stemLen] — простой стемминг.
///  4. Считает долю совпавших токенов и сортирует по убыванию.
class SymptomMatcher {
  SymptomMatcher._();

  /// Минимальная длина общего префикса для засчитывания совпадения.
  static const int _stemLen = 4;

  /// Минимальная длина токена, чтобы он участвовал в сравнении.
  static const int _minTokenLen = 3;

  /// Русские стоп-слова. Верхний регистр — не важен, всё идёт в lower.
  static const Set<String> _stopWords = {
    'и',
    'в',
    'во',
    'не',
    'что',
    'он',
    'на',
    'я',
    'с',
    'со',
    'как',
    'а',
    'то',
    'все',
    'всё',
    'она',
    'так',
    'его',
    'но',
    'да',
    'ты',
    'к',
    'у',
    'же',
    'вы',
    'за',
    'бы',
    'по',
    'только',
    'ее',
    'её',
    'мне',
    'было',
    'вот',
    'от',
    'меня',
    'еще',
    'ещё',
    'нет',
    'о',
    'об',
    'из',
    'ему',
    'теперь',
    'когда',
    'даже',
    'ну',
    'вдруг',
    'ли',
    'если',
    'уже',
    'или',
    'ни',
    'быть',
    'был',
    'него',
    'до',
    'вас',
    'нибудь',
    'опять',
    'уж',
    'вам',
    'ведь',
    'там',
    'потом',
    'себя',
    'ничего',
    'ей',
    'может',
    'они',
    'тут',
    'где',
    'есть',
    'надо',
    'ней',
    'для',
    'мы',
    'тебя',
    'их',
    'чем',
    'была',
    'сам',
    'чтоб',
    'без',
    'будто',
    'чего',
    'раз',
    'тоже',
    'себе',
    'под',
    'будет',
    'ж',
    'тогда',
    'кто',
    'этот',
    'того',
    'потому',
    'этого',
    'какой',
    'совсем',
    'ним',
    'здесь',
    'этом',
    'один',
    'почти',
    'мой',
    'тем',
    'чтобы',
    'нее',
    'неё',
    'сейчас',
    'были',
    'куда',
    'зачем',
    'всех',
    'никогда',
    'можно',
    'при',
    'наконец',
    'два',
    'другой',
    'хоть',
    'после',
    'над',
    'больше',
    'тот',
    'через',
    'эти',
    'нас',
    'про',
    'всего',
    'них',
    'какая',
    'много',
    'разве',
    'три',
    'эту',
    'моя',
    'впрочем',
    'хорошо',
    'свою',
    'этой',
    'перед',
    'иногда',
    'лучше',
    'чуть',
    'том',
    'нельзя',
    'такой',
    'им',
    'более',
    'всегда',
    'конечно',
    'всю',
    'между',
  };

  /// Найти болезни, подходящие под запрос.
  static List<SymptomMatch> match({
    required String query,
    required List<PlantDisease> diseases,
    int topN = 5,
    double threshold = 0.15,
  }) {
    final queryTokens = _tokenize(query);
    if (queryTokens.isEmpty) return const [];

    final results = <SymptomMatch>[];

    for (final d in diseases) {
      final corpus = _buildCorpus(d);
      final corpusTokens = _tokenize(corpus);
      if (corpusTokens.isEmpty) continue;

      final matched = <String>[];
      for (final qt in queryTokens) {
        if (corpusTokens.any((ct) => _fuzzyEq(qt, ct))) {
          matched.add(qt);
        }
      }

      if (matched.isEmpty) continue;

      final score = matched.length / queryTokens.length;
      if (score < threshold) continue;

      results.add(
        SymptomMatch(
          disease: d,
          score: score,
          matchedTokens: matched,
          totalTokens: queryTokens.length,
        ),
      );
    }

    results.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return a.disease.name.compareTo(b.disease.name);
    });

    return results.take(topN).toList(growable: false);
  }

  /// Строит текстовый корпус болезни: имя + описание + симптомы.
  static String _buildCorpus(PlantDisease d) {
    final buffer = StringBuffer();
    buffer.write(d.name);
    buffer.write(' ');
    if (d.description != null) {
      buffer.write(d.description);
      buffer.write(' ');
    }
    if (d.symptomsJson != null && d.symptomsJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(d.symptomsJson!);
        if (decoded is List) {
          for (final item in decoded) {
            buffer.write(item.toString());
            buffer.write(' ');
          }
        } else if (decoded is String) {
          buffer.write(decoded);
          buffer.write(' ');
        }
      } catch (_) {
        buffer.write(d.symptomsJson);
      }
    }
    return buffer.toString();
  }

  /// Разбивает строку на значимые токены.
  static List<String> _tokenize(String text) {
    if (text.isEmpty) return const [];
    final cleaned = text.toLowerCase().replaceAll(
      RegExp(r'[^а-яёa-z0-9\s]+', unicode: true),
      ' ',
    );
    final raw = cleaned.split(RegExp(r'\s+'));
    final result = <String>{};
    for (final w in raw) {
      if (w.length < _minTokenLen) continue;
      if (_stopWords.contains(w)) continue;
      result.add(w);
    }
    return result.toList(growable: false);
  }

  /// Нечёткое сравнение: общий префикс длиной ≥ [_stemLen].
  static bool _fuzzyEq(String a, String b) {
    if (a == b) return true;
    final len = a.length < b.length ? a.length : b.length;
    if (len < _stemLen) return false;
    for (var i = 0; i < _stemLen; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
