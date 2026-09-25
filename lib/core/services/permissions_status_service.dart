import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Сервис проверки и запроса разрешений, от которых зависят
/// уведомления приложения.
///
/// Три пункта, за которыми следит сервис:
///  1. Разрешение на уведомления (`POST_NOTIFICATIONS`, Android 13+).
///  2. Разрешение на точные будильники (`SCHEDULE_EXACT_ALARM`).
///  3. Фоновая работа (актуально для Honor/Huawei/Xiaomi — открывается
///     системный экран «Управление запуском приложений»).
///
/// Никакого Foreground Service не используется: уведомления работают
/// через `alarmClock`, который не требует постоянного напоминания в
/// шторке.
class PermissionsStatusService {
  PermissionsStatusService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  /// Есть ли разрешение на показ уведомлений.
  Future<bool> hasNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) return false;
      final enabled = await android.areNotificationsEnabled();
      return enabled ?? false;
    } catch (e) {
      log('areNotificationsEnabled упал: $e');
      return false;
    }
  }

  /// Есть ли разрешение на точные будильники.
  ///
  /// На Android 12+ без этого разрешения `alarmClock`-уведомления
  /// могут задерживаться или не приходить вовсе.
  Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) return false;
      final can = await android.canScheduleExactNotifications();
      return can ?? false;
    } catch (e) {
      log('canScheduleExactNotifications упал: $e');
      return false;
    }
  }

  /// Запрос разрешения на уведомления. Возвращает результат.
  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) return false;
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    } catch (e) {
      log('requestNotificationsPermission упал: $e');
      return false;
    }
  }

  /// Запрос разрешения на точные будильники. Возвращает результат.
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) return false;
      final granted = await android.requestExactAlarmsPermission();
      return granted ?? false;
    } catch (e) {
      log('requestExactAlarmsPermission упал: $e');
      return false;
    }
  }

  /// Открыть системные настройки уведомлений приложения.
  Future<void> openNotificationSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    } catch (e) {
      log('openAppSettings(notification) упал: $e');
    }
  }

  /// Открыть системные настройки батареи приложения.
  Future<void> openBatterySettings() async {
    try {
      await AppSettings.openAppSettings(
        type: AppSettingsType.batteryOptimization,
      );
    } catch (e) {
      log('openAppSettings(batteryOptimization) упал: $e');
    }
  }

  /// Открыть системные настройки приложения (общий экран).
  Future<void> openAppSettings() async {
    try {
      await AppSettings.openAppSettings();
    } catch (e) {
      log('openAppSettings() упал: $e');
    }
  }

  /// Открыть экран «Управление запуском приложений» (Honor/Huawei).
  ///
  /// На разных прошивках активити называется по-разному, поэтому
  /// пробуем несколько intent'ов по очереди. Если ничего не сработало
  /// — открываем общий экран настроек приложения.
  Future<void> openAutoStartSettings() async {
    if (!Platform.isAndroid) return;

    // Список возможных активити для Honor/Huawei/Xiaomi/Oppo/Vivo.
    // Первый сработавший — используем.
    const candidateActions = <String>[
      // Honor / Huawei
      'com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity',
      // Xiaomi / MIUI
      'com.miui.securitycenter.permission.AppPermissionsEditor',
      // Oppo / ColorOS
      'com.coloros.safecenter.startupapp.StartupAppListActivity',
      // Vivo / Funtouch OS
      'com.iqoo.secure.ui.phoneoptimize.BgStartUpManager',
      // Универсальные настройки приложения
      'android.settings.APPLICATION_DETAILS_SETTINGS',
    ];

    for (final action in candidateActions) {
      try {
        final intent = action == 'android.settings.APPLICATION_DETAILS_SETTINGS'
            ? AndroidIntent(
                action: action,
                data: 'package:com.pykaxaoca.pocketbotanist',
                flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
              )
            : AndroidIntent(
                action: action,
                flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
              );
        await intent.launch();
        log('AutoStart: сработал intent $action');
        return;
      } catch (e) {
        log('AutoStart: intent $action не сработал: $e');
        // пробуем следующий
      }
    }

    // Фолбэк — общие настройки приложения.
    log('AutoStart: все intent\'ы упали, открываю общие настройки');
    await openAppSettings();
  }

  void log(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[PermissionsStatus] $message');
    }
  }
}
