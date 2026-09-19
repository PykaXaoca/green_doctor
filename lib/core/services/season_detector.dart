/// Определение текущей стадии роста растения.
///
/// Простая реализация по месяцу. В дальнейшем можно уточнять по
/// температуре и региону — сигнатура метода уже готова.
class SeasonDetector {
  const SeasonDetector();

  /// Возвращает одну из стадий:
  /// spring / growing / flowering / fruiting / dormant.
  ///
  /// Для комнатных растений сезонность сглажена:
  /// осень-зима — относительный покой, весна-лето — рост.
  String currentStage({
    required bool? isIndoor,
    DateTime? plantedAt,
    DateTime? now,
  }) {
    final date = now ?? DateTime.now();
    final month = date.month;

    // Комнатные: упрощённая схема.
    if (isIndoor == true) {
      if (month >= 11 || month <= 2) return 'dormant';
      return 'growing';
    }

    // Садовые: 5 стадий по месяцам.
    if (month >= 3 && month <= 4) return 'spring';
    if (month >= 5 && month <= 6) return 'flowering';
    if (month >= 7 && month <= 9) return 'fruiting';
    return 'dormant'; // октябрь — февраль
  }

  /// Человекочитаемый заголовок стадии.
  String title(String stage) {
    switch (stage) {
      case 'spring':
        return '🌸 Весеннее пробуждение';
      case 'growing':
        return '🌱 Активный рост';
      case 'flowering':
        return '🌼 Цветение';
      case 'fruiting':
        return '🍎 Плодоношение';
      case 'dormant':
        return '❄️ Покой и подготовка к зиме';
      default:
        return stage;
    }
  }

  /// Порядок отображения всех стадий (для экрана «Все стадии»).
  static const List<String> allStages = [
    'spring',
    'growing',
    'flowering',
    'fruiting',
    'dormant',
  ];
}
