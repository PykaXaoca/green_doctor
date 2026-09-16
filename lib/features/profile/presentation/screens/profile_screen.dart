import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/service_providers.dart';
import '../providers/profile_providers.dart';

/// Экран профиля: аватар, уровень, XP, статистика, достижения,
/// история XP и опасная зона.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(profileDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Настройки',
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(profileDataProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(data: data),
              const SizedBox(height: 16),
              _StatsCard(data: data),
              const SizedBox(height: 16),
              const _AchievementsSection(),
              const SizedBox(height: 16),
              _HistorySection(data: data),
              const SizedBox(height: 16),
              _PremiumCard(data: data),
              const SizedBox(height: 16),
              _AboutSection(),
              const SizedBox(height: 16),
              _DangerZone(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
//  Шапка
// =========================================================================

class _HeaderCard extends ConsumerWidget {
  const _HeaderCard({required this.data});

  final ProfileData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gamification = ref.watch(gamificationServiceProvider);
    final progress = gamification.progressToNextLevel(
      xp: data.user.xp,
      level: data.user.level,
    );
    final nextLevelXp = gamification.xpForNextLevel(data.user.level);
    final currentLevelXp = gamification.xpRequiredForLevel(data.user.level);

    final avatarPath = data.user.avatarPath;
    final hasAvatar = avatarPath != null && File(avatarPath).existsSync();

    final name = data.user.displayName ?? 'Садовод';
    final city = data.user.city;
    final bio = data.user.bio;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: hasAvatar ? FileImage(File(avatarPath)) : null,
              child: !hasAvatar
                  ? Text(
                      _initials(name),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (city != null && city.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 14,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    city,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
            if (bio != null && bio.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                bio,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'С нами ${data.daysInApp} ${_daysWord(data.daysInApp)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Уровень ${data.user.level}',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '${data.user.xp} XP',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$currentLevelXp XP', style: theme.textTheme.bodySmall),
                Text('$nextLevelXp XP', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push('/profile/edit'),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Редактировать профиль'),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return 'С';
    return name.trim().substring(0, 1).toUpperCase();
  }

  String _daysWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'день';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
      return 'дня';
    }
    return 'дней';
  }
}

// =========================================================================
//  Статистика
// =========================================================================

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.data});

  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статистика', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.local_florist,
                    label: 'Растений',
                    value: data.plantCount.toString(),
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.archive_outlined,
                    label: 'В архиве',
                    value: data.archivedCount.toString(),
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.emoji_events,
                    label: 'Достижений',
                    value: data.unlockedCodes.length.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.check_circle_outline,
                    label: 'Действий',
                    value: data.careEventCount.toString(),
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.calendar_month,
                    label: 'За месяц',
                    value: data.careEventsThisMonth.toString(),
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.local_fire_department,
                    label: 'Серия',
                    value: '${data.streakDays} дн.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 26),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// =========================================================================
//  Достижения
// =========================================================================

class _AchievementsSection extends ConsumerWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsViewProvider);
    final unlocked = achievements.where((a) => a.unlocked).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Достижения',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '$unlocked из ${achievements.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: achievements
                  .map((a) => _AchievementBadge(view: a))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.view});

  final AchievementView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = view.unlocked;
    final color = unlocked
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Tooltip(
      message: unlocked
          ? '${view.def.name}\n${view.def.description}'
          : '${view.def.name} (закрыто)',
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: unlocked ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Icon(
            unlocked ? Icons.emoji_events : Icons.lock_outline,
            color: color,
            size: 28,
          ),
        ),
      ),
    );
  }
}

// =========================================================================
//  История XP
// =========================================================================

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.data});

  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    if (data.recentXp.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Последние начисления',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...data.recentXp.take(5).map((e) {
              final (icon, label) = _reasonMeta(e.reason);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label)),
                    Text(
                      '+${e.amount} XP',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  (IconData, String) _reasonMeta(String reason) {
    if (reason.startsWith('achievement:')) {
      return (Icons.emoji_events, 'Достижение');
    }
    switch (reason) {
      case 'add_plant':
        return (Icons.add, 'Добавление растения');
      case 'watering':
        return (Icons.water_drop, 'Полив');
      case 'fertilizing':
        return (Icons.eco, 'Удобрение');
      case 'misting':
        return (Icons.spa, 'Опрыскивание');
      case 'repotting':
        return (Icons.redeem, 'Пересадка');
      default:
        return (Icons.star, reason);
    }
  }
}

// =========================================================================
//  Premium
// =========================================================================

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.data});

  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium = data.user.subscriptionTier != 'free';
    final expiry = data.user.subscriptionExpiry;

    return Card(
      color: isPremium
          ? Colors.amber.withValues(alpha: 0.15)
          : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isPremium ? Icons.star : Icons.star_outline,
              color: isPremium
                  ? Colors.amber.shade700
                  : theme.colorScheme.outline,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? 'Premium активен' : 'Бесплатная версия',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPremium
                        ? (expiry != null
                              ? 'Действует до ${_formatDate(expiry)}'
                              : 'Все возможности открыты')
                        : 'Ограниченный набор функций',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPremium)
              FilledButton.tonal(
                onPressed: () => context.push('/paywall'),
                child: const Text('Открыть'),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}

// =========================================================================
//  О приложении
// =========================================================================

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('О приложении'),
            subtitle: const Text('Версия, назначение, технологии'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/settings/about'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Все настройки'),
            subtitle: const Text('Уведомления, тема, расписание'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/settings'),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
//  Опасная зона
// =========================================================================

class _DangerZone extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DangerZone> createState() => _DangerZoneState();
}

class _DangerZoneState extends ConsumerState<_DangerZone> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Опасная зона',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            enabled: !_busy,
            leading: Icon(
              Icons.cleaning_services_outlined,
              color: theme.colorScheme.error,
            ),
            title: const Text('Очистить журнал ухода'),
            subtitle: const Text('Удалить все события. Растения остаются.'),
            onTap: _busy ? null : _confirmClearHistory,
          ),
          const Divider(height: 1),
          ListTile(
            enabled: !_busy,
            leading: Icon(
              Icons.delete_sweep_outlined,
              color: theme.colorScheme.error,
            ),
            title: const Text('Удалить архивные растения'),
            subtitle: const Text('Растения из архива будут удалены полностью.'),
            onTap: _busy ? null : _confirmDeleteArchived,
          ),
          const Divider(height: 1),
          ListTile(
            enabled: !_busy,
            leading: Icon(Icons.restart_alt, color: theme.colorScheme.error),
            title: const Text('Полный сброс данных'),
            subtitle: const Text(
              'Удалить все растения, события, диагнозы и прогресс.',
            ),
            onTap: _busy ? null : _confirmFullReset,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory() async {
    final ok = await _confirm(
      title: 'Очистить журнал?',
      body:
          'Все события ухода будут удалены. Растения останутся. '
          'Действие нельзя отменить.',
    );
    if (ok != true) return;
    await _run(() async {
      await ref.read(userProfileControllerProvider).clearCareHistory();
      _snack('Журнал очищен');
    });
  }

  Future<void> _confirmDeleteArchived() async {
    final ok = await _confirm(
      title: 'Удалить архивные растения?',
      body:
          'Все растения из архива будут удалены со всеми связанными '
          'данными. Действие нельзя отменить.',
    );
    if (ok != true) return;
    await _run(() async {
      final count = await ref
          .read(userProfileControllerProvider)
          .deleteArchivedPlants();
      _snack('Удалено растений: $count');
    });
  }

  Future<void> _confirmFullReset() async {
    final ok = await _confirm(
      title: 'Полный сброс?',
      body:
          'Будут удалены все растения, события, диагнозы, напоминания '
          'и прогресс. Имя, город и аватар сохранятся. '
          'Действие нельзя отменить.',
      destructive: true,
    );
    if (ok != true) return;
    await _run(() async {
      await ref.read(userProfileControllerProvider).fullReset();
      _snack('Данные сброшены');
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      _snack('Ошибка: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool?> _confirm({
    required String title,
    required String body,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(destructive ? 'Сбросить' : 'Очистить'),
          ),
        ],
      ),
    );
  }
}
