import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/router/app_router.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/pt_calendar/providers/pt_calendar_provider.dart';
import '../../../../shared/models/personal_event_model.dart';
import '../../../../shared/models/session_model.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../providers/personal_event_provider.dart';
import 'add_personal_event_screen.dart';

class MemberCalendarScreen extends ConsumerStatefulWidget {
  const MemberCalendarScreen({super.key});

  @override
  ConsumerState<MemberCalendarScreen> createState() =>
      _MemberCalendarScreenState();
}

class _MemberCalendarScreenState extends ConsumerState<MemberCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) =>
          Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _CalendarContent(
          memberId: user.uid,
          memberName: user.name,
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          onDaySelected: (selected, focused) => setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          }),
          isSameDay: _isSameDay,
        );
      },
    );
  }
}

class _CalendarContent extends ConsumerWidget {
  final String memberId;
  final String memberName;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final bool Function(DateTime, DateTime) isSameDay;

  const _CalendarContent({
    required this.memberId,
    required this.memberName,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.isSameDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalEventsAsync =
        ref.watch(memberPersonalEventsProvider(memberId));
    final sessionsAsync = ref.watch(memberSessionsProvider(memberId));
    final theme = Theme.of(context);

    final personalEvents = personalEventsAsync.valueOrNull ?? [];
    final sessions = sessionsAsync.valueOrNull ?? [];

    // Events for selected day
    final dayPersonalEvents = personalEvents
        .where((e) => isSameDay(e.dateTime, selectedDay))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final daySessions = sessions
        .where((s) =>
            isSameDay(s.dateTime, selectedDay) &&
            s.status != SessionStatus.cancelled)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvimim'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.booking),
            icon: const Icon(Icons.event_available, size: 18),
            label: const Text('Randevu'),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Object>(
            locale: 'tr_TR',
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            onDaySelected: onDaySelected,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              todayTextStyle:
                  TextStyle(color: theme.colorScheme.onPrimaryContainer),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              final hasPersonal =
                  personalEvents.any((e) => isSameDay(e.dateTime, day));
              final hasSession = sessions.any((s) =>
                  isSameDay(s.dateTime, day) &&
                  s.status != SessionStatus.cancelled);
              final markers = <Object>[];
              if (hasPersonal) markers.add('personal');
              if (hasSession) markers.add('session');
              return markers;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.map((e) {
                    final color = e == 'session'
                        ? Colors.green
                        : theme.colorScheme.secondary;
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: (dayPersonalEvents.isEmpty && daySessions.isEmpty)
                ? AppEmpty(
                    message: DateFormat('d MMMM', 'tr').format(selectedDay),
                    subMessage: 'Bu gün için etkinlik yok',
                    icon: Icons.event_note_outlined,
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      ...daySessions.map((s) => _SessionTile(session: s)),
                      ...dayPersonalEvents.map((e) => _PersonalEventTile(
                          event: e, memberId: memberId)),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddPersonalEventScreen(
              memberId: memberId,
              initialDate: selectedDay,
            ),
          ),
        ),
        tooltip: 'Etkinlik Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionModel session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(session.dateTime);
    final statusColor = switch (session.status) {
      SessionStatus.confirmed => Colors.green,
      SessionStatus.pending => Colors.orange,
      _ => Colors.grey,
    };
    final statusLabel = switch (session.status) {
      SessionStatus.confirmed => 'Onaylandı',
      SessionStatus.pending => 'Bekliyor',
      SessionStatus.completed => 'Tamamlandı',
      _ => '',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.sports_gymnastics,
              color: Colors.green, size: 20),
        ),
        title: Text(
          'PT Randevusu',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
            '$timeStr • ${session.durationMinutes} dk'),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(statusLabel,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _PersonalEventTile extends ConsumerWidget {
  final PersonalEventModel event;
  final String memberId;

  const _PersonalEventTile(
      {required this.event, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm').format(event.dateTime);
    final dMin = event.durationMinutes;
    final durStr = dMin < 60
        ? '$dMin dk'
        : '${dMin ~/ 60} sa${dMin % 60 != 0 ? ' ${dMin % 60} dk' : ''}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.fitness_center,
              color: theme.colorScheme.secondary, size: 20),
        ),
        title: Text(event.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$timeStr • $durStr'),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline,
              color: theme.colorScheme.error, size: 20),
          onPressed: () => _confirmDelete(context, ref),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Etkinliği Sil'),
        content: Text('"${event.title}" etkinliğini silmek istiyor musunuz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('İptal')),
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Sil')),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(personalEventRepositoryProvider)
          .deleteEvent(event.id);
    }
  }
}
