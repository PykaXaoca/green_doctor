import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_providers.dart';

/// Режим дачного графика полива.
enum CareScheduleMode {
  /// Свободный график: каждое растение по своему циклу.
  free('Свободный', 'Каждое растение по своему циклу'),

  /// Единый интервал: пользователь приезжает раз в N дней.
  interval('Раз в N дней', 'Ездите на дачу через равные промежутки'),

  /// Фиксированные дни недели: пользователь выбрал дни.
  weekdays('По дням недели', 'Например, только суббота и воскресенье');

  const CareScheduleMode(this.label, this.description);
  final String label;
  final String description;

  static CareScheduleMode fromString(String? value) {
    switch (value) {
      case 'interval':
        return CareScheduleMode.interval;
      case 'weekdays':
        return CareScheduleMode.weekdays;
      default:
        return CareScheduleMode.free;
    }
  }
}

/// Настройка дачного графика.
class CareScheduleConfig {
  const CareScheduleConfig({
    this.mode = CareScheduleMode.free,
    this.intervalDays = 3,
    this.weekdays = const {6, 7},
    this.startDate,
  });

  final CareScheduleMode mode;

  /// Для mode == interval. От 1 до 30.
  final int intervalDays;

  /// Для mode == weekdays. Дни недели по ISO:
  /// 1 = понедельник ... 7 = воскресенье.
  final Set<int> weekdays;

  /// Дата отсчёта для interval. Обычно сегодня при первом сохранении.
  final DateTime? startDate;

  CareScheduleConfig copyWith({
    CareScheduleMode? mode,
    int? intervalDays,
    Set<int>? weekdays,
    DateTime? startDate,
  }) {
    return CareScheduleConfig(
      mode: mode ?? this.mode,
      intervalDays: intervalDays ?? this.intervalDays,
      weekdays: weekdays ?? this.weekdays,
      startDate: startDate ?? this.startDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'intervalDays': intervalDays,
    'weekdays': weekdays.toList()..sort(),
    'startDate': startDate?.toIso8601String(),
  };

  factory CareScheduleConfig.fromJson(Map<String, dynamic> json) {
    return CareScheduleConfig(
      mode: CareScheduleMode.fromString(json['mode'] as String?),
      intervalDays: (json['intervalDays'] as int?) ?? 3,
      weekdays: json['weekdays'] is List
          ? (json['weekdays'] as List).whereType<int>().toSet()
          : const {6, 7},
      startDate: json['startDate'] is String
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
    );
  }
}

/// Ключ в `app_meta`.
const String _kConfigKey = 'care_schedule_config';

/// Notifier настроек — читает из БД, пишет в БД.
///
/// ВНИМАНИЕ: не переопределяем `update` из `AsyncNotifier` —
/// используем собственное имя `save`, чтобы не ловить
/// конфликт с сигнатурой базового класса.
class CareScheduleNotifier extends AsyncNotifier<CareScheduleConfig> {
  @override
  Future<CareScheduleConfig> build() async {
    final db = ref.watch(databaseProvider);
    final raw = await db.appMetaDao.getValue(_kConfigKey);
    if (raw == null || raw.isEmpty) {
      return const CareScheduleConfig();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CareScheduleConfig.fromJson(map);
    } catch (_) {
      return const CareScheduleConfig();
    }
  }

  /// Сохраняет настройку в БД и обновляет state.
  Future<void> save(CareScheduleConfig config) async {
    final db = ref.read(databaseProvider);
    await db.appMetaDao.setValue(_kConfigKey, jsonEncode(config.toJson()));
    state = AsyncData(config);
  }

  Future<void> setMode(CareScheduleMode mode) async {
    final current = state.asData?.value ?? const CareScheduleConfig();
    await save(current.copyWith(mode: mode));
  }

  Future<void> setIntervalDays(int days) async {
    final current = state.asData?.value ?? const CareScheduleConfig();
    await save(
      current.copyWith(
        intervalDays: days.clamp(1, 30),
        // При изменении интервала — пересчитываем дату старта от сегодня.
        startDate: DateTime.now(),
      ),
    );
  }

  Future<void> toggleWeekday(int isoDay) async {
    final current = state.asData?.value ?? const CareScheduleConfig();
    final set = Set<int>.from(current.weekdays);
    if (set.contains(isoDay)) {
      // Не даём снять последний день.
      if (set.length <= 1) return;
      set.remove(isoDay);
    } else {
      set.add(isoDay);
    }
    await save(current.copyWith(weekdays: set));
  }

  Future<void> reset() async {
    await save(const CareScheduleConfig());
  }
}

final careScheduleProvider =
    AsyncNotifierProvider<CareScheduleNotifier, CareScheduleConfig>(
      CareScheduleNotifier.new,
    );

/// Читаемые подписи дней недели (ISO → короткое название).
const Map<int, String> kWeekdayNames = {
  1: 'Пн',
  2: 'Вт',
  3: 'Ср',
  4: 'Чт',
  5: 'Пт',
  6: 'Сб',
  7: 'Вс',
};
