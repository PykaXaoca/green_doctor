import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/service_providers.dart';
import '../../../../core/providers/settings_providers.dart';

/// Центр уведомлений — экран управления разрешениями и настройками
/// напоминаний.
///
/// Разделён на две части:
///  * **Чек-лист разрешений** — три пункта: уведомления, точные
///    будильники, фоновая работа (для Honor/Huawei/Xiaomi).
///  * **Настройки напоминаний** — включение, время, группировка,
///    уведомления о лечении, диагностика.
class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Центр уведомлений')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _IntroCard(),
          SizedBox(height: 16),
          _PermissionsChecklist(),
          SizedBox(height: 16),
          _NotificationSettingsCard(),
          SizedBox(height: 16),
          _DiagnosticsCard(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ============================================================================
//  Вводный блок
// ============================================================================

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Уведомления вовремя',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Чтобы напоминания приходили точно в назначенное время, '
              'нужны три разрешения. Проверьте чек-лист ниже — если '
              'что-то не выдано, нажмите кнопку рядом с пунктом.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
//  Чек-лист разрешений
// ============================================================================

/// Провайдер статуса всех трёх разрешений.
final _permissionsStatusProvider = FutureProvider<_PermissionsStatus>((
  ref,
) async {
  final service = ref.read(permissionsStatusServiceProvider);

  final notif = await service.hasNotificationPermission();
  final exact = await service.hasExactAlarmPermission();

  return _PermissionsStatus(notifications: notif, exactAlarms: exact);
});

class _PermissionsStatus {
  const _PermissionsStatus({
    required this.notifications,
    required this.exactAlarms,
  });

  final bool notifications;
  final bool exactAlarms;
}

class _PermissionsChecklist extends ConsumerWidget {
  const _PermissionsChecklist();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusAsync = ref.watch(_permissionsStatusProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist_rounded),
                const SizedBox(width: 8),
                Text('Разрешения', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),

            statusAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Ошибка: $err'),
              data: (status) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PermissionRow(
                    title: 'Разрешение на уведомления',
                    description:
                        'Без него приложение не сможет показать ни одного '
                        'напоминания. Система Android 13+ запрашивает его '
                        'отдельно.',
                    granted: status.notifications,
                    actionLabel: status.notifications ? null : 'Выдать',
                    onAction: status.notifications
                        ? null
                        : () => _requestNotification(context, ref),
                  ),
                  const Divider(height: 24),
                  _PermissionRow(
                    title: 'Точные будильники',
                    description:
                        'Без него напоминания могут задерживаться на 15+ минут '
                        'или вообще не срабатывать в режиме сна.',
                    granted: status.exactAlarms,
                    actionLabel: status.exactAlarms
                        ? null
                        : 'Открыть настройки',
                    onAction: status.exactAlarms
                        ? null
                        : () => _requestExactAlarm(context, ref),
                  ),
                  const Divider(height: 24),
                  _PermissionRow(
                    title: 'Фоновая работа (для Honor, Xiaomi)',
                    description:
                        'На некоторых прошивках система останавливает '
                        'приложения в фоне. Разрешите автозапуск и работу '
                        'в фоне — уведомления будут приходить стабильнее.',
                    granted: null,
                    actionLabel: 'Открыть настройки Honor',
                    onAction: () => _openAutoStart(ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestNotification(BuildContext context, WidgetRef ref) async {
    final service = ref.read(permissionsStatusServiceProvider);
    final granted = await service.requestNotificationPermission();
    if (!context.mounted) return;

    ref.invalidate(_permissionsStatusProvider);

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Разрешение не выдано. Можно выдать его вручную в '
            'системных настройках приложения.',
          ),
        ),
      );
    }
  }

  Future<void> _requestExactAlarm(BuildContext context, WidgetRef ref) async {
    final service = ref.read(permissionsStatusServiceProvider);
    await service.requestExactAlarmPermission();
    if (!context.mounted) return;
    ref.invalidate(_permissionsStatusProvider);
  }

  Future<void> _openAutoStart(WidgetRef ref) async {
    final service = ref.read(permissionsStatusServiceProvider);
    await service.openAutoStartSettings();
  }
}

/// Строка одного разрешения.
class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.title,
    required this.description,
    required this.granted,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;

  /// null = статус неизвестен (для Honor); true/false = выдан/нет.
  final bool? granted;

  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final IconData statusIcon;
    final Color statusColor;
    if (granted == null) {
      statusIcon = Icons.info_outline;
      statusColor = theme.colorScheme.outline;
    } else if (granted == true) {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green.shade700;
    } else {
      statusIcon = Icons.cancel;
      statusColor = theme.colorScheme.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              children: [
                FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
//  Настройки напоминаний
// ============================================================================

class _NotificationSettingsCard extends ConsumerWidget {
  const _NotificationSettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Card(
      child: settingsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Ошибка: $err'),
        ),
        data: (settings) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.tune),
                  const SizedBox(width: 8),
                  Text('Настройки', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            SwitchListTile(
              title: const Text('Включить уведомления'),
              subtitle: const Text('Напоминания о поливе и лечении'),
              value: settings.enabled,
              onChanged: (v) => _toggleEnabled(context, ref, v),
            ),
            const Divider(height: 1),
            ListTile(
              enabled: settings.enabled,
              leading: const Icon(Icons.schedule),
              title: const Text('Время напоминания'),
              subtitle: Text(settings.summaryTimeLabel),
              trailing: const Icon(Icons.chevron_right),
              onTap: settings.enabled
                  ? () => _pickTime(context, ref, settings.summaryTime)
                  : null,
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Группировать по дням'),
              subtitle: const Text(
                'Одно уведомление «Полить N растений» вместо отдельных',
              ),
              value: settings.groupByDay,
              onChanged: settings.enabled
                  ? (v) => _change(ref, (n) => n.setGroupByDay(v))
                  : null,
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Уведомления о лечении'),
              subtitle: const Text('Напоминания о шагах лечения'),
              value: settings.treatmentEnabled,
              onChanged: settings.enabled
                  ? (v) => _change(ref, (n) => n.setTreatmentEnabled(v))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleEnabled(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    if (value) {
      final service = ref.read(notificationServiceProvider);
      final granted = await service.requestPermissions();
      if (!granted) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Разрешение на уведомления не выдано. Выдайте его вручную '
              'в системных настройках.',
            ),
          ),
        );
        return;
      }
    }
    await _change(ref, (n) => n.setEnabled(value));
  }

  /// Применяет изменение настроек.
  ///
  /// **Не вызывает** `syncAll` — это делается централизованно в
  /// `app.dart` через `ref.listen(notificationSettingsProvider)`.
  /// Иначе уведомления пересоздаются дважды.
  Future<void> _change(
    WidgetRef ref,
    Future<void> Function(NotificationSettingsNotifier) action,
  ) async {
    await action(ref.read(notificationSettingsProvider.notifier));
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay current,
  ) async {
    final chosen = await showTimePicker(
      context: context,
      initialTime: current,
      helpText: 'Выберите время напоминания',
      cancelText: 'Отмена',
      confirmText: 'ОК',
      hourLabelText: 'Часы',
      minuteLabelText: 'Минуты',
    );
    if (chosen == null) return;
    await _change(ref, (n) => n.setSummaryTime(chosen));
  }
}

// ============================================================================
//  Диагностика
// ============================================================================

class _DiagnosticsCard extends ConsumerWidget {
  const _DiagnosticsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.bug_report_outlined),
                const SizedBox(width: 8),
                Text('Диагностика', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Тестовое уведомление'),
            subtitle: const Text('Показать уведомление сразу'),
            onTap: () async {
              final service = ref.read(notificationServiceProvider);
              await service.showTestNotification();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Тестовое уведомление отправлено'),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Показать диагностику в логах'),
            subtitle: const Text('Текущее состояние для отладки'),
            onTap: () async {
              final service = ref.read(notificationServiceProvider);
              await service.logDiagnostics();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Диагностика выведена в консоль')),
              );
            },
          ),
        ],
      ),
    );
  }
}
