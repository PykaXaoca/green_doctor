import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/providers/settings_providers.dart';

/// Экран настроек приложения.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AppearanceSection(),
          SizedBox(height: 16),
          _NotificationsSection(),
          SizedBox(height: 16),
          _CareSection(),
          SizedBox(height: 16),
          _AboutSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ============================================================================
//  Внешний вид
// ============================================================================

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modeAsync = ref.watch(appThemeModeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined),
                const SizedBox(width: 8),
                Text(
                  'Внешний вид',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            modeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Ошибка: $err'),
              data: (mode) => Wrap(
                spacing: 8,
                children: AppThemeMode.values.map((m) {
                  return ChoiceChip(
                    label: Text(m.label),
                    avatar: Icon(m.icon, size: 18),
                    selected: m == mode,
                    onSelected: (_) =>
                        ref.read(appThemeModeProvider.notifier).set(m),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
//  Уведомления
// ============================================================================

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final theme = Theme.of(context);

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
                  const Icon(Icons.notifications_outlined),
                  const SizedBox(width: 8),
                  Text('Уведомления', style: theme.textTheme.titleMedium),
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
              subtitle: Text(
                '${settings.summaryHour.toString().padLeft(2, '0')}:00',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: settings.enabled
                  ? () => _pickHour(context, ref, settings.summaryHour)
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

  /// Переключение основного переключателя уведомлений.
  ///
  /// При включении сначала запрашиваем системное разрешение.
  /// Если пользователь откажет — не переключаем и показываем
  /// подсказку.
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
              'Разрешение на уведомления не выдано. '
              'Откройте настройки Android и разрешите уведомления '
              'для этого приложения.',
            ),
          ),
        );
        return;
      }
    }
    await _change(ref, (n) => n.setEnabled(value));
  }

  /// Применяет изменение и пересобирает расписание уведомлений.
  Future<void> _change(
    WidgetRef ref,
    Future<void> Function(NotificationSettingsNotifier) action,
  ) async {
    await action(ref.read(notificationSettingsProvider.notifier));

    final settings = ref.read(notificationSettingsSyncProvider);
    final service = ref.read(notificationServiceProvider);
    service.updateSettings(settings);

    final plantRepo = ref.read(plantRepositoryProvider);
    final plants = await plantRepo.getAllActive();
    await service.syncAll(plants);
  }

  Future<void> _pickHour(
    BuildContext context,
    WidgetRef ref,
    int currentHour,
  ) async {
    final hours = List.generate(24, (i) => i);
    final chosen = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView.builder(
        itemCount: hours.length,
        itemBuilder: (context, i) {
          final h = hours[i];
          final selected = h == currentHour;
          return ListTile(
            leading: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            title: Text('${h.toString().padLeft(2, '0')}:00'),
            onTap: () => Navigator.of(context).pop(h),
          );
        },
      ),
    );

    if (chosen != null) {
      await _change(ref, (n) => n.setSummaryHour(chosen));
    }
  }
}

// ============================================================================
//  Уход
// ============================================================================

class _CareSection extends StatelessWidget {
  const _CareSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.agriculture_outlined),
                const SizedBox(width: 8),
                Text('Уход', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Расписание полива'),
            subtitle: const Text('Просмотр на 14 дней вперёд'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/watering-schedule'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.home_work_outlined),
            title: const Text('Режим дачника'),
            subtitle: const Text('Полив в один день'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/care-schedule'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  Прочее
// ============================================================================

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                Text('Прочее', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Premium'),
            subtitle: const Text('Открыть все возможности'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Premium будет доступен в следующих версиях'),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('О приложении'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/settings/about'),
          ),
        ],
      ),
    );
  }
}
