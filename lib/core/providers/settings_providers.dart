import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_providers.dart';

// ============================================================================
//  Тема оформления
// ============================================================================

enum AppThemeMode {
  light('Светлая', Icons.light_mode),
  dark('Тёмная', Icons.dark_mode),
  system('Системная', Icons.brightness_auto);

  const AppThemeMode(this.label, this.icon);
  final String label;
  final IconData icon;

  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

class AppThemeModeNotifier extends AsyncNotifier<AppThemeMode> {
  static const _key = 'app_theme_mode';

  @override
  Future<AppThemeMode> build() async {
    final db = ref.watch(databaseProvider);
    final raw = await db.appMetaDao.getValue(_key);
    return AppThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> set(AppThemeMode mode) async {
    final db = ref.read(databaseProvider);
    await db.appMetaDao.setValue(_key, mode.name);
    state = AsyncData(mode);
  }
}

final appThemeModeProvider =
    AsyncNotifierProvider<AppThemeModeNotifier, AppThemeMode>(
      AppThemeModeNotifier.new,
    );

// ============================================================================
//  Уведомления
// ============================================================================

class NotificationSettings {
  const NotificationSettings({
    this.enabled = true,
    this.summaryHour = 9,
    this.groupByDay = true,
    this.treatmentEnabled = true,
  });

  final bool enabled;
  final int summaryHour; // 0..23
  final bool groupByDay;
  final bool treatmentEnabled;

  NotificationSettings copyWith({
    bool? enabled,
    int? summaryHour,
    bool? groupByDay,
    bool? treatmentEnabled,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      summaryHour: summaryHour ?? this.summaryHour,
      groupByDay: groupByDay ?? this.groupByDay,
      treatmentEnabled: treatmentEnabled ?? this.treatmentEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'summaryHour': summaryHour,
    'groupByDay': groupByDay,
    'treatmentEnabled': treatmentEnabled,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: (json['enabled'] as bool?) ?? true,
      summaryHour: (json['summaryHour'] as int?) ?? 9,
      groupByDay: (json['groupByDay'] as bool?) ?? true,
      treatmentEnabled: (json['treatmentEnabled'] as bool?) ?? true,
    );
  }
}

class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettings> {
  static const _key = 'notification_settings';

  @override
  Future<NotificationSettings> build() async {
    final db = ref.watch(databaseProvider);
    final raw = await db.appMetaDao.getValue(_key);
    if (raw == null || raw.isEmpty) return const NotificationSettings();
    try {
      return NotificationSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const NotificationSettings();
    }
  }

  Future<void> _save(NotificationSettings settings) async {
    final db = ref.read(databaseProvider);
    await db.appMetaDao.setValue(_key, jsonEncode(settings.toJson()));
    state = AsyncData(settings);
  }

  Future<void> setEnabled(bool enabled) async {
    final c = state.asData?.value ?? const NotificationSettings();
    await _save(c.copyWith(enabled: enabled));
  }

  Future<void> setSummaryHour(int hour) async {
    final c = state.asData?.value ?? const NotificationSettings();
    await _save(c.copyWith(summaryHour: hour.clamp(0, 23)));
  }

  Future<void> setGroupByDay(bool value) async {
    final c = state.asData?.value ?? const NotificationSettings();
    await _save(c.copyWith(groupByDay: value));
  }

  Future<void> setTreatmentEnabled(bool value) async {
    final c = state.asData?.value ?? const NotificationSettings();
    await _save(c.copyWith(treatmentEnabled: value));
  }

  Future<void> reset() async {
    await _save(const NotificationSettings());
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );

/// Кэш-версия настроек уведомлений — для использования в сервисе
/// уведомлений и в местах, где `await` неудобен.
final notificationSettingsSyncProvider = Provider<NotificationSettings>((ref) {
  final async = ref.watch(notificationSettingsProvider);
  return async.asData?.value ?? const NotificationSettings();
});
