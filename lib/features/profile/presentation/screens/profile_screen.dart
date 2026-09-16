import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/service_providers.dart';
import '../providers/profile_providers.dart';

/// Экран профиля: аватар, уровень, XP, достижения, статистика.
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                _initials(data.user.displayName ?? 'С'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.user.displayName ?? 'Садовод',
              style: theme.textTheme.titleLarge,
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
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return 'С';
    return name.trim().substring(0, 1).toUpperCase();
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.data});

  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статистика', style: Theme.of(context).textTheme.titleMedium),
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
                    icon: Icons.check_circle,
                    label: 'Действий',
                    value: data.careEventCount.toString(),
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
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleLarge),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _AchievementsSection extends ConsumerWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsViewProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Достижения', style: Theme.of(context).textTheme.titleMedium),
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
