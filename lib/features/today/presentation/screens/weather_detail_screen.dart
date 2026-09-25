import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/weather_service.dart';

/// Подробный экран погоды.
///
/// Показывает:
///  * большая карточка «Сейчас»;
///  * «Сегодня» — подробно;
///  * «Завтра» — подробно;
///  * следующие 5 дней — компактный список.
class WeatherDetailScreen extends ConsumerWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Погода'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () => ref.invalidate(currentWeatherProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(currentWeatherProvider),
        child: weatherAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Ошибка: $err'),
                ),
              ),
            ],
          ),
          data: (weather) {
            if (weather == null) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _InfoCard(
                    icon: Icons.location_off,
                    title: 'Погода недоступна',
                    message:
                        'Включите геолокацию и проверьте подключение к интернету, '
                        'затем потяните экран вниз для обновления.',
                  ),
                ],
              );
            }
            return _buildBody(context, weather);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherSnapshot weather) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CurrentCard(weather: weather),
        const SizedBox(height: 16),

        if (weather.today != null) ...[
          Text('Сегодня', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _DayDetailCard(day: weather.today!, today: true),
          const SizedBox(height: 16),
        ],

        if (weather.tomorrow != null) ...[
          Text('Завтра', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _DayDetailCard(day: weather.tomorrow!, today: false),
          const SizedBox(height: 16),
        ],

        _buildUpcoming(weather, theme),
      ],
    );
  }

  Widget _buildUpcoming(WeatherSnapshot weather, ThemeData theme) {
    // Первые два элемента — сегодня и завтра; начинаем с третьего.
    final upcoming = weather.daily.length > 2
        ? weather.daily.sublist(2, weather.daily.length).take(5).toList()
        : const <DailyForecast>[];

    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Следующие 5 дней', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < upcoming.length; i++) ...[
                _UpcomingRow(day: upcoming[i]),
                if (i < upcoming.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// =========================================================================
//  Блок «Сейчас»
// =========================================================================

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.weather});

  final WeatherSnapshot weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = DateFormat('HH:mm').format(weather.fetchedAt);

    // Собираем чипы только для полей, которые есть в ответе.
    // Meteosource Free не отдаёт влажность, давление, UV —
    // соответствующие чипы просто не появятся.
    final chips = <Widget>[
      if (weather.currentHumidity != null)
        _ChipMetric(
          icon: Icons.water_drop_outlined,
          label: 'Влажность',
          value: '${weather.currentHumidity}%',
        ),
      if (weather.windSpeed > 0)
        _ChipMetric(
          icon: Icons.air,
          label: 'Ветер',
          value:
              '${weather.windSpeed.toStringAsFixed(1)} м/с '
              '${_windDir(weather.windDirection)}',
        ),
      if (weather.pressure != null && weather.pressure! > 0)
        _ChipMetric(
          icon: Icons.speed,
          label: 'Давление',
          value: '${weather.pressure!.round()} гПа',
        ),
      if (weather.uvIndex != null)
        _ChipMetric(
          icon: Icons.wb_sunny_outlined,
          label: 'UV',
          value: weather.uvIndex!.toStringAsFixed(0),
        ),
      if (weather.cloudCover > 0)
        _ChipMetric(
          icon: Icons.cloud_outlined,
          label: 'Облачность',
          value: '${weather.cloudCover}%',
        ),
    ];

    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _weatherIcon(weather.currentIcon),
                  size: 64,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.currentTemp.round()}°C',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        weather.currentDescription,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      if (weather.apparentTemp != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Ощущается как '
                          '${weather.apparentTemp!.round()}°C',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 8, children: chips),
            ],
            const SizedBox(height: 12),
            Text(
              'Обновлено в $time',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipMetric extends StatelessWidget {
  const _ChipMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
//  Блок «Сегодня» / «Завтра»
// =========================================================================

class _DayDetailCard extends StatelessWidget {
  const _DayDetailCard({required this.day, required this.today});

  final DailyForecast day;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_weatherIcon(day.icon), size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${day.tempMin.round()}° / ${day.tempMax.round()}°',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (day.description.isNotEmpty)
                        Text(
                          day.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row(
              theme,
              Icons.umbrella_outlined,
              'Осадки',
              '${(day.precipitationProbability * 100).round()}% · '
                  '${day.precipitationSum.toStringAsFixed(1)} мм',
            ),
            if (day.windSpeedMax != null)
              _row(
                theme,
                Icons.air,
                'Ветер',
                '${day.windSpeedMax!.toStringAsFixed(1)} м/с'
                    '${day.windDirectionDominant != null ? ' ${_windDir(day.windDirectionDominant!)}' : ''}',
              ),
            if (day.uvIndexMax != null)
              _row(
                theme,
                Icons.wb_sunny_outlined,
                'UV-индекс',
                day.uvIndexMax!.toStringAsFixed(0),
              ),
            if (day.sunrise != null)
              _row(
                theme,
                Icons.wb_twilight,
                'Восход',
                DateFormat('HH:mm').format(day.sunrise!),
              ),
            if (day.sunset != null)
              _row(
                theme,
                Icons.nights_stay_outlined,
                'Закат',
                DateFormat('HH:mm').format(day.sunset!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

// =========================================================================
//  Блок «Следующие 5 дней»
// =========================================================================

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.day});

  final DailyForecast day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekday = DateFormat('EEEE', 'ru').format(day.date);
    final dateStr = DateFormat('d MMM', 'ru').format(day.date);
    final cap = weekday.isNotEmpty
        ? weekday[0].toUpperCase() + weekday.substring(1)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cap,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Icon(_weatherIcon(day.icon), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${day.tempMin.round()}° / ${day.tempMax.round()}°',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.water_drop_outlined,
                size: 14,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                '${(day.precipitationProbability * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================================
//  Вспомогательное
// =========================================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Двузначный код иконки (`01`, `10`, `50`…) → `IconData`.
IconData _weatherIcon(String iconCode) {
  if (iconCode.isEmpty) return Icons.wb_cloudy;
  if (iconCode.startsWith('01')) return Icons.wb_sunny;
  if (iconCode.startsWith('02') || iconCode.startsWith('03')) {
    return Icons.wb_cloudy;
  }
  if (iconCode.startsWith('04')) return Icons.cloud;
  if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
    return Icons.grain;
  }
  if (iconCode.startsWith('11')) return Icons.flash_on;
  if (iconCode.startsWith('13')) return Icons.ac_unit;
  if (iconCode.startsWith('50')) return Icons.foggy;
  return Icons.wb_cloudy;
}

/// Градусы → сторона света: С, СВ, В, ЮВ, Ю, ЮЗ, З, СЗ.
String _windDir(int degrees) {
  const dirs = ['С', 'СВ', 'В', 'ЮВ', 'Ю', 'ЮЗ', 'З', 'СЗ'];
  final normalized = ((degrees % 360) + 360) % 360;
  final index = ((normalized + 22.5) ~/ 45) % 8;
  return dirs[index];
}
