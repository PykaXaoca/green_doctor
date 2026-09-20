import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
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
///
/// Планирование идёт через [_scheduleSafely]: сначала пытаемся
/// использовать точные alarm'ы (`exactAllowWhileIdle`) — они не
/// задерживаются системой в Doze. Если разрешение на exact alarms
/// не выдано (Android 12+), фолбэчимся на `inexactAllowWhileIdle`.
///
/// Разрешения **не запрашиваются** при инициализации. Их запрашивает
/// UI в момент, когда пользователь включает уведомления в настройках
/// (см. [requestPermissions]).
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

  /// Имя drawable-ресурса иконки уведомлений. Должно совпадать с
  /// `flutter_launcher_icons.android` в pubspec.
  static const String _iconName = '@mipmap/launcher_icon';

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

  /// Инициализация плагина.
  ///
  /// **Разрешения не запрашиваются.** Они запрашиваются отдельно
  /// через [requestPermissions], когда пользователь явно включает
  /// уведомления в настройках.
  Future<void> initialize() async {
    if (_initialized) return;

    // --- Таймзоны ---
    tz.initializeTimeZones();
    _setupLocalTimezone();

    const androidInit = AndroidInitializationSettings(_iconName);
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxInit = LinuxInitializationSettings(defaultActionName: 'Открыть');
    const windowsInit = WindowsInitializationSettings(
      appName: 'Карманный ботаник',
      appUserModelId: 'com.pykaxaoca.pocketbotanist',
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

    // --- Явно создаём канал на Android ---
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    _initialized = true;
  }

  /// Тихая проверка: выдано ли разрешение на уведомления (без диалога).
  ///
  /// На iOS/macOS всегда возвращает `true` — там разрешения
  /// запрашиваются только через [requestPermissions].
  Future<bool> hasPermissions() async {
    if (!Platform.isAndroid) return true;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;

    try {
      final enabled = await android.areNotificationsEnabled();
      return enabled ?? false;
    } catch (e) {
      log('areNotificationsEnabled упал: $e');
      return false;
    }
  }

  /// Запросить разрешения на уведомления и (мягко) на exact alarms.
  ///
  /// Возвращает `true`, если разрешение на обычные уведомления
  /// выдано. Разрешение на exact alarms запрашивается «мягко»:
  /// если пользователь откажет, планирование всё равно сработает
  /// в inexact-режиме (см. [_scheduleSafely]).
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) return false;

      bool granted = false;
      try {
        final result = await android.requestNotificationsPermission();
        granted = result ?? false;
        log('POST_NOTIFICATIONS granted: $granted');
      } catch (e) {
        log('requestNotificationsPermission упал: $e');
        return false;
      }

      // Разрешение на exact alarms — «мягко».
      try {
        final exact = await android.requestExactAlarmsPermission();
        log('SCHEDULE_EXACT_ALARM granted: $exact');
      } catch (e) {
        log('requestExactAlarmsPermission недоступен: $e');
      }

      return granted;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Устанавливает локальную таймзону по текущему смещению системы.
  ///
  /// Без пакета `flutter_timezone` нельзя получить IANA-имя зоны,
  /// зато можно подобрать фиксированное смещение `Etc/GMT±N`.
  /// (В базе IANA знак инвертирован: `Etc/GMT-5` = UTC+5.)
  void _setupLocalTimezone() {
    try {
      final offsetHours = DateTime.now().timeZoneOffset.inHours;
      final sign = offsetHours >= 0 ? '-' : '+';
      final abs = offsetHours.abs();
      final zoneName = 'Etc/GMT$sign$abs';
      tz.setLocalLocation(tz.getLocation(zoneName));
      log(
        'Таймзона: $zoneName (UTC${offsetHours >= 0 ? '+' : ''}$offsetHours)',
      );
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      log('Не удалось установить локальную таймзону, использую UTC: $e');
    }
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

  /// Отладочный вывод списка запланированных уведомлений.
  Future<void> _logPending() async {
    if (!kDebugMode) return;
    try {
      final pending = await _plugin.pendingNotificationRequests();
      log('Запланировано уведомлений: ${pending.length}');
      for (final p in pending.take(10)) {
        log('  • id=${p.id} title="${p.title}"');
      }
    } catch (e) {
      log('pendingNotificationRequests недоступен: $e');
    }
  }

  /// Планирует уведомление с попыткой использовать exact-режим.
  ///
  /// Если система не разрешает exact alarms (Android 12+ без явного
  /// разрешения), ловим исключение и повторяем с inexact-режимом.
  /// Это гарантирует, что уведомление будет запланировано в любом
  /// случае, но с разной точностью.
  Future<void> _scheduleSafely({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required NotificationDetails details,
    String? payload,
  }) async {
    final tzWhen = tz.TZDateTime.from(when, tz.local);

    if (Platform.isAndroid) {
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzWhen,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
        return;
      } on PlatformException catch (e) {
        log('exactAllowWhileIdle недоступен (${e.code}), фолбэк на inexact');
      } catch (e) {
        log('exactAllowWhileIdle упал: $e, фолбэк на inexact');
      }
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzWhen,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  // =========================================================================
  //  Полив — синхронизация
  // =========================================================================

  /// Полная синхронизация уведомлений о поливе.
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

    if (!_settings.enabled) {
      log('Уведомления выключены в настройках');
      return;
    }

    if (_settings.groupByDay) {
      await _syncGrouped(plants, today);
    } else {
      await _syncIndividual(plants, now);
    }

    await _logPending();
  }

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
        icon: _iconName,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );

    await _scheduleSafely(
      id: _idFor('watering', plant.id),
      title: 'Пора полить ${plant.customName}',
      body: 'Нажмите, чтобы отметить полив',
      when: when,
      details: details,
      payload: 'plant:${plant.id}',
    );
  }

  Future<void> _scheduleSummary({
    required DateTime day,
    required List<Plant> plants,
    required DateTime scheduled,
    required bool hasOverdue,
  }) async {
    final body = _formatBody(plants);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: _iconName,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
      linux: const LinuxNotificationDetails(),
      windows: const WindowsNotificationDetails(),
    );

    final count = plants.length;
    final title = hasOverdue ? 'Полив: есть просроченные' : 'Полив на сегодня';

    await _scheduleSafely(
      id: _idFor('watering_summary', _dayKey(day)),
      title: title,
      body: body,
      when: scheduled,
      details: details,
      payload: 'watering_summary',
    );

    log('Групповое уведомление на $scheduled: $count раст.');
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
        icon: _iconName,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );

    await _scheduleSafely(
      id: _idFor('reminder', reminderId),
      title: title,
      body: body,
      when: when,
      details: details,
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
        icon: _iconName,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );

    await _scheduleSafely(
      id: _idFor('treatment', stepId),
      title: 'Лечение: $diseaseName',
      body: stepTitle,
      when: when,
      details: details,
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
        icon: _iconName,
        playSound: true,
        enableVibration: true,
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
    log('Тестовое уведомление показано');
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
