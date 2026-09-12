import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../plants/presentation/providers/plant_providers.dart';
import '../providers/calendar_providers.dart';

/// Экран календаря с запланированными и выполненными событиями.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Сегодня',
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _focusedDay = now;
                _selectedDay = now;
              });
            },
          ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
        data: (eventsByDay) {
          return Column(
            children: [
              _buildCalendar(eventsByDay),
              const Divider(height: 1),
              Expanded(child: _buildEventList(eventsByDay)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(Map<DateTime, List<CalendarEvent>> eventsByDay) {
    return TableCalendar<CalendarEvent>(
      locale: 'ru',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      currentDay: DateTime.now(),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Месяц'},
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
        ref
            .read(calendarRangeProvider.notifier)
            .setRange(
              DateTimeRange(
                start: DateTime(focused.year, focused.month, 1),
                end: DateTime(focused.year, focused.month + 1, 0, 23, 59, 59),
              ),
            );
      },
      eventLoader: (day) => eventsByDay[_dateOnly(day)] ?? const [],
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildEventList(Map<DateTime, List<CalendarEvent>> eventsByDay) {
    final key = _dateOnly(_selectedDay);
    final events = eventsByDay[key] ?? const <CalendarEvent>[];

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'На этот день событий нет',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d MMMM yyyy', 'ru').format(_selectedDay),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            DateFormat('d MMMM yyyy, EEEE', 'ru').format(_selectedDay),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...events.map((e) => _EventTile(event: e)),
      ],
    );
  }
}

class _EventTile extends ConsumerStatefulWidget {
  const _EventTile({required this.event});

  final CalendarEvent event;

  @override
  ConsumerState<_EventTile> createState() => _EventTileState();
}

class _EventTileState extends ConsumerState<_EventTile> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final (icon, color, label) = _eventMeta(e.type);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(
            decoration: e.isCompleted ? TextDecoration.lineThrough : null,
            color: e.isCompleted ? theme.colorScheme.outline : null,
          ),
        ),
        subtitle: Text(e.plantName),
        trailing: e.isCompleted
            ? Icon(Icons.check_circle, color: Colors.green.shade600)
            : _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : FilledButton.tonal(
                onPressed: _complete,
                child: const Text('Выполнить'),
              ),
        onTap: () => context.push('/plants/${e.plantId}'),
      ),
    );
  }

  Future<void> _complete() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(careActionControllerProvider);
      await controller.perform(
        plantId: widget.event.plantId,
        type: widget.event.type,
      );
      ref.invalidate(calendarEventsProvider);
      if (mounted) {
        final label = _eventMeta(widget.event.type).$3.toLowerCase();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.event.plantName}: $label отмечено')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  (IconData, Color, String) _eventMeta(String type) {
    switch (type) {
      case 'watering':
        return (Icons.water_drop, Colors.blue, 'Полив');
      case 'fertilizing':
        return (Icons.eco, Colors.green, 'Удобрение');
      case 'misting':
        return (Icons.spa, Colors.teal, 'Опрыскивание');
      case 'repotting':
        return (Icons.redeem, Colors.brown, 'Пересадка');
      default:
        return (Icons.event, Colors.grey, type);
    }
  }
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
