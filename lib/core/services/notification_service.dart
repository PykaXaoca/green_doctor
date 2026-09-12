import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../database/database.dart';

/// Сервис локальных уведомлений о необходимости ухода за растениями.
class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'pocket_botanist_care';
  static const String _channelName = 'Уход за растениями';
  static const String _channelDescription =
      'Напоминания о поливе, удобрении и других действиях';

  /// Инициализация: таймзона, канал, разрешения.
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxInit = LinuxInitializationSettings(defaultActionName: 'Открыть');
    const windowsInit = WindowsInitializationSettings(
      appName: 'Карманный ботаник',
      appUserModelId: 'com.yourcompany.pocket_botanist',
      guid: 'a3f5c8e0-7b21-4f6a-9d1e-6c4f2a1b8e3d',
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      macOS: iosInit,
      linux: linuxInit,
      windows: windowsInit,
    );

    await _plugin.initialize(settings: initSettings);

    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    } else if (Platform.isIOS || Platform.isMacOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Планирование уведомления о поливе.
  Future<void> scheduleWatering({
    required int plantId,
    required String plantName,
    required DateTime when,
  }) async {
    if (!_initialized) await initialize();
    if (!when.isAfter(DateTime.now())) return;

    final notificationId = _idFor('watering', plantId);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const linuxDetails = LinuxNotificationDetails();
    const windowsDetails = WindowsNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      title: 'Пора полить $plantName',
      body: 'Нажмите, чтобы отметить полив',
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'plant:$plantId',
    );
  }

  /// Планирование произвольного напоминания.
  Future<void> scheduleReminder({
    required int reminderId,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    if (!_initialized) await initialize();
    if (!when.isAfter(DateTime.now())) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: _idFor('reminder', reminderId),
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Отменить уведомление о поливе.
  Future<void> cancelWatering(int plantId) async {
    if (!_initialized) await initialize();
    await _plugin.cancel(id: _idFor('watering', plantId));
  }

  /// Отменить конкретное напоминание.
  Future<void> cancelReminder(int reminderId) async {
    if (!_initialized) await initialize();
    await _plugin.cancel(id: _idFor('reminder', reminderId));
  }

  /// Отменить все уведомления.
  Future<void> cancelAll() async {
    if (!_initialized) await initialize();
    await _plugin.cancelAll();
  }

  /// Показать тестовое уведомление (для отладки).
  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );
    await _plugin.show(
      id: 999,
      title: 'Тестовое уведомление',
      body: 'Если вы видите это — уведомления работают',
      notificationDetails: details,
    );
  }

  /// Уникальный id уведомления из типа и сущности.
  int _idFor(String type, int entityId) {
    final prefix = type.hashCode & 0xFF;
    return (prefix << 24) | (entityId & 0xFFFFFF);
  }

  /// Пересчитать уведомления для растения.
  Future<void> rescheduleForPlant(Plant plant) async {
    await cancelWatering(plant.id);

    final due = plant.nextWaterDue;
    if (due == null) return;
    if (plant.isArchived) return;

    await scheduleWatering(
      plantId: plant.id,
      plantName: plant.customName,
      when: due,
    );
  }

  /// Отменить все уведомления, связанные с растением.
  Future<void> cancelForPlant(int plantId) async {
    await cancelWatering(plantId);
  }

  /// Пересчитать все уведомления по списку растений.
  Future<void> syncAll(List<Plant> plants) async {
    for (final p in plants) {
      if (p.isArchived) {
        await cancelWatering(p.id);
      } else {
        await rescheduleForPlant(p);
      }
    }
  }

  /// Логирование (для отладки).
  void log(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[NotificationService] $message');
    }
  }
}
