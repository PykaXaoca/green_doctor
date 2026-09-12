import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/database/database.dart';
import 'package:pocket_botanist/core/services/watering_advisor.dart';
import 'package:pocket_botanist/core/services/weather_service.dart';

void main() {
  const advisor = WateringAdvisor();

  Plant buildPlant({int? frequencyDays}) => Plant(
    id: 1,
    userId: 1,
    customName: 'Тест',
    wateringFrequencyDays: frequencyDays ?? 7,
    createdAt: DateTime(2026, 1, 1),
    isArchived: false,
  );

  WeatherSnapshot buildWeather({
    double temp = 20,
    int humidity = 50,
    double todayPrecip = 0.0,
    double tomorrowPrecip = 0.0,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return WeatherSnapshot(
      fetchedAt: now,
      currentTemp: temp,
      currentHumidity: humidity,
      currentDescription: 'ясно',
      currentIcon: '01d',
      currentDt: now,
      daily: [
        DailyForecast(
          date: today,
          tempMin: temp - 5,
          tempMax: temp + 5,
          precipitationProbability: todayPrecip,
        ),
        DailyForecast(
          date: tomorrow,
          tempMin: temp - 5,
          tempMax: temp + 5,
          precipitationProbability: tomorrowPrecip,
        ),
      ],
    );
  }

  test('Без погоды — стандартная рекомендация', () {
    final rec = advisor.advise(plant: buildPlant(), weather: null);
    expect(rec.action, WateringAction.water);
  });

  test('Завтра дождь > 60% — отложить', () {
    final rec = advisor.advise(
      plant: buildPlant(),
      weather: buildWeather(tomorrowPrecip: 0.8),
    );
    expect(rec.action, WateringAction.postpone);
  });

  test('Сегодня и завтра дождь > 70% — пропустить', () {
    final rec = advisor.advise(
      plant: buildPlant(),
      weather: buildWeather(todayPrecip: 0.8, tomorrowPrecip: 0.8),
    );
    expect(rec.action, WateringAction.skip);
  });

  test('Жарко и сухо — срочно', () {
    final rec = advisor.advise(
      plant: buildPlant(),
      weather: buildWeather(temp: 35, humidity: 20),
    );
    expect(rec.action, WateringAction.urgent);
  });

  test('Холодно — отложить', () {
    final rec = advisor.advise(
      plant: buildPlant(),
      weather: buildWeather(temp: 5),
    );
    expect(rec.action, WateringAction.postpone);
  });

  test('Нормальная погода — полить', () {
    final rec = advisor.advise(
      plant: buildPlant(),
      weather: buildWeather(temp: 22, humidity: 50),
    );
    expect(rec.action, WateringAction.water);
  });
}
