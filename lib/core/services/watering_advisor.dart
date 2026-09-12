import '../database/database.dart';
import 'weather_service.dart';

/// Рекомендация по поливу.
class WateringRecommendation {
  const WateringRecommendation({
    required this.action,
    required this.message,
    this.adjustedDueDate,
  });

  /// Что делать.
  final WateringAction action;

  /// Текст рекомендации для UI.
  final String message;

  /// Предлагаемая новая дата полива (если рекомендуется отложить).
  final DateTime? adjustedDueDate;
}

enum WateringAction {
  /// Обычный полив.
  water,

  /// Отложить — скоро дождь.
  postpone,

  /// Пропустить — несколько дней дождя.
  skip,

  /// Срочно полить — жара и сухость.
  urgent,
}

/// Сервис рекомендаций по поливу с учётом погоды.
class WateringAdvisor {
  const WateringAdvisor();

  /// Возвращает рекомендацию для растения [plant] с учётом [weather].
  WateringRecommendation advise({
    required Plant plant,
    required WeatherSnapshot? weather,
  }) {
    if (weather == null) {
      return const WateringRecommendation(
        action: WateringAction.water,
        message: 'Погода недоступна. Поливайте как обычно.',
      );
    }

    final today = weather.today;
    final tomorrow = weather.tomorrow;
    final frequency = plant.wateringFrequencyDays ?? 7;

    // 1. Сначала — самое специфичное: два дня дождя подряд → пропустить.
    if (today != null &&
        today.precipitationProbability > 0.7 &&
        tomorrow != null &&
        tomorrow.precipitationProbability > 0.7) {
      return const WateringRecommendation(
        action: WateringAction.skip,
        message: 'Два дня дождя подряд. Полив можно пропустить.',
      );
    }

    // 2. Завтра дождь > 60% → отложить.
    if (tomorrow != null && tomorrow.precipitationProbability > 0.6) {
      final percent = (tomorrow.precipitationProbability * 100).round();
      return WateringRecommendation(
        action: WateringAction.postpone,
        message: 'Завтра дождь ($percent%). Можно отложить полив на день.',
        adjustedDueDate: DateTime.now().add(const Duration(days: 1)),
      );
    }

    // 3. Жарко и сухо → срочно полить.
    if (weather.currentTemp > 30 && weather.currentHumidity < 30) {
      final nextDays = (frequency - 1).clamp(1, 30);
      return WateringRecommendation(
        action: WateringAction.urgent,
        message:
            'Жарко (${weather.currentTemp.round()}°C) и сухо. '
            'Полейте сегодня, следующий полив через $nextDays дн.',
      );
    }

    // 4. Холодно → отложить и уменьшить объём.
    if (weather.currentTemp < 10) {
      return WateringRecommendation(
        action: WateringAction.postpone,
        message:
            'Прохладно (${weather.currentTemp.round()}°C). '
            'Уменьшите объём полива, чтобы не застудить корни.',
        adjustedDueDate: DateTime.now().add(const Duration(days: 2)),
      );
    }

    // 5. Обычная ситуация.
    return WateringRecommendation(
      action: WateringAction.water,
      message:
          'Погода нормальная (${weather.currentTemp.round()}°C). '
          'Поливайте как обычно.',
    );
  }
}
