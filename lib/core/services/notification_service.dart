import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../database/database.dart';
import '../providers/settings_providers.dart';

/// Сервис локальных уведомлений о необходимости ухода за растениями.
///
/// Уведомления о поливе **группируются по дню**, если это включено в
/// настройках: вместо отдельного уведомления на каждое растение
/// приходит одно — «Сегодня полить N растений». Группировку можно
/// выключить в настройках.
class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Актуальные настройки. Обновляются через [updateSettings] при
  /// старте приложения и при каждом изменении в настройках.
  NotificationSettings _settings = const NotificationSettings();

  /// Горизонт планирования — 14 дней.
  static const int _summaryHorizonDays = 14;

  /// Callback для обработки тапа по уведомлению.
  void Function(String? payload)? onNotificationTap;

  static const String _channelId = 'pocket_botanist_care';
  static const String _channelName = 'Уход за растениями';
  static const String _channelDescription =
      'Напоминания о поливе, удобрении и других действиях';

  static const int _maxNotificationId = 0x7FFFFFFF;

  static const Map<String, int> _typePrefixes = <String, int>{
    'watering': 1,
    'fertilizing': 2,
    'misting': 3,
    'repotting': 4,
    'reminder': 5,
    'diagnosis': 6,
    'treatment': 7,
    'weather': 8,
    'watering_summary': 9,
  };

  /// Обновляет настройки сервиса.
  void updateSettings(NotificationSettings settings) {
    _settings = settings;
  }

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

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    await _requestPermissions();
    _initialized = true;
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    onNotificationTap?.call(response.payload);
  }

  Future<String?> getLaunchPayload() async {
    if (!_initialized) await initialize();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse?.payload;
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

  // =========================================================================
  //  Полив — синхронизация
  // =========================================================================

  /// Полная синхронизация уведомлений о поливе.
  ///
  /// Работает в двух режимах:
  ///  * **с группировкой** (`_settings.groupByDay == true`): одно
  ///    уведомление на день, со списком растений;
  ///  * **индивидуально**: отдельное уведомление на каждое растение
  ///    в его рекомендуемую дату.
  ///
  /// Если уведомления отключены (`_settings.enabled == false`),
  /// все запланированные уведомления о поливе отменяются.
  Future<void> syncAll(List<Plant> plants) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    final today = _dateOnly(now);

    // Всегда сначала отменяем всё запланированное.
    for (var i = 0; i < _summaryHorizonDays + 1; i++) {
      final day = today.add(Duration(days: i));
      await _plugin.cancel(id: _idFor('watering_summary', _dayKey(day)));
    }
    for (final p in plants) {
      await _plugin.cancel(id: _idFor('watering', p.id));
    }

    // Если уведомления отключены — на этом всё.
    if (!_settings.enabled) return;

    if (_settings.groupByDay) {
      await _syncGrouped(plants, today);
    } else {
      await _syncIndividual(plants, now);
    }
  }

  /// Групповой режим — одно уведомление в день.
  Future<void> _syncGrouped(List<Plant> plants, DateTime today) async {
    final Map<DateTime, List<Plant>> byDay = {};
    final overdue = <Plant>[];

    for (final plant in plants) {
      if (plant.isArchived) continue;
      final due = plant.nextWaterDue;
      if (due == null) continue;
      final dueDay = _dateOnly(due);

      if (dueDay.isBefore(today)) {
        overdue.add(plant);
        continue;
      }

      final daysAhead = dueDay.difference(today).inDays;
      if (daysAhead > _summaryHorizonDays) continue;

      byDay.putIfAbsent(dueDay, () => <Plant>[]).add(plant);
    }

    for (final list in byDay.values) {
      list.sort(
        (a, b) =>
            a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
      );
    }
    overdue.sort(
      (a, b) =>
          a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
    );

    final todayList = [...overdue, ...(byDay[today] ?? const <Plant>[])]
      ..sort(
        (a, b) =>
            a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
      );

    if (todayList.isNotEmpty) {
      var scheduled = DateTime(
        today.year,
        today.month,
        today.day,
        _settings.summaryHour,
      );
      final now = DateTime.now();
      if (!scheduled.isAfter(now)) {
        scheduled = now.add(const Duration(minutes: 1));
      }
      await _scheduleSummary(
        day: today,
        plants: todayList,
        scheduled: scheduled,
        hasOverdue: overdue.isNotEmpty,
      );
    }

    final now = DateTime.now();
    for (final entry in byDay.entries) {
      if (_sameDay(entry.key, today)) continue;
      final list = entry.value;
      if (list.isEmpty) continue;

      final scheduled = DateTime(
        entry.key.year,
        entry.key.month,
        entry.key.day,
        _settings.summaryHour,
      );
      if (!scheduled.isAfter(now)) continue;

      await _scheduleSummary(
        day: entry.key,
        plants: list,
        scheduled: scheduled,
        hasOverdue: false,
      );
    }
  }

  /// Индивидуальный режим — по одному уведомлению на растение.
  Future<void> _syncIndividual(List<Plant> plants, DateTime now) async {
    for (final plant in plants) {
      if (plant.isArchived) continue;
      final due = plant.nextWaterDue;
      if (due == null) continue;
      if (!due.isAfter(now)) continue;

      final daysAhead = due.difference(now).inDays;
      if (daysAhead > _summaryHorizonDays) continue;

      await _scheduleIndividualWatering(plant, due);
    }
  }

  Future<void> _scheduleIndividualWatering(Plant plant, DateTime when) async {
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
      id: _idFor('watering', plant.id),
      title: 'Пора полить ${plant.customName}',
      body: 'Нажмите, чтобы отметить полив',
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'plant:${plant.id}',
    );
  }

  Future<void> _scheduleSummary({
    required DateTime day,
    required List<Plant> plants,
    required DateTime scheduled,
    required bool hasOverdue,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );

    final count = plants.length;
    final title = hasOverdue ? 'Полив: есть просроченные' : 'Полив на сегодня';
    final body = _formatBody(plants);

    await _plugin.zonedSchedule(
      id: _idFor('watering_summary', _dayKey(day)),
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'watering_summary',
    );

    log('Групповое уведомление на $day: $count раст.');
  }

  String _formatBody(List<Plant> plants) {
    final names = plants.map((p) => p.customName).toList();
    final count = names.length;

    if (count == 1) return 'Полить: ${names.first}';
    if (count <= 3) {
      return 'Полить $count ${_plantWord(count)}: ${names.join(', ')}';
    }

    final firstTwo = names.take(2).join(', ');
    return 'Полить $count ${_plantWord(count)}: $firstTwo и ещё ${count - 2}';
  }

  String _plantWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'растение';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
      return 'растения';
    }
    return 'растений';
  }

  // =========================================================================
  //  Отмена
  // =========================================================================

  Future<void> scheduleReminder({
    required int reminderId,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    if (!_initialized) await initialize();
    if (!_settings.enabled) return;
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

  Future<void> cancelReminder(int reminderId) async {
    if (!_initialized) await initialize();
    await _plugin.cancel(id: _idFor('reminder', reminderId));
  }

  Future<void> cancelWatering(int plantId) async {
    if (!_initialized) await initialize();
    await _plugin.cancel(id: _idFor('watering', plantId));
  }

  Future<void> cancelForPlant(int plantId) => cancelWatering(plantId);

  Future<void> cancelAll() async {
    if (!_initialized) await initialize();
    await _plugin.cancelAll();
  }

  // =========================================================================
  //  Лечение
  // =========================================================================

  Future<void> scheduleTreatmentStep({
    required int stepId,
    required int diagnosisId,
    required String diseaseName,
    required String stepTitle,
    required DateTime when,
  }) async {
    if (!_initialized) await initialize();
    if (!_settings.enabled || !_settings.treatmentEnabled) return;
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
      id: _idFor('treatment', stepId),
      title: 'Лечение: $diseaseName',
      body: stepTitle,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'treatment:$diagnosisId:$stepId',
    );
  }

  Future<void> cancelTreatmentStep(int stepId) async {
    if (!_initialized) await initialize();
    await _plugin.cancel(id: _idFor('treatment', stepId));
  }

  // =========================================================================
  //  Тестовое уведомление
  // =========================================================================

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
      id: _normalizeId(999),
      title: 'Тестовое уведомление',
      body: 'Если вы видите это — уведомления работают',
      notificationDetails: details,
    );
  }

  // =========================================================================
  //  Идентификаторы
  // =========================================================================

  int _normalizeId(int raw) {
    assert(
      _maxNotificationId == 0x7FFFFFFF,
      'Максимальный id уведомления должен быть 2^31 - 1',
    );
    return raw & _maxNotificationId;
  }

  int _idFor(String type, int entityId) {
    final int rawPrefix = _typePrefixes[type] ?? (type.hashCode & 0x7F);
    final int prefix = rawPrefix & 0x7F;
    final int entityBits = entityId & 0xFFFFFF;
    final int raw = (prefix << 24) | entityBits;
    return _normalizeId(raw);
  }

  int _dayKey(DateTime day) => day.year * 10000 + day.month * 100 + day.day;

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void log(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[NotificationService] $message');
    }
  }
}
