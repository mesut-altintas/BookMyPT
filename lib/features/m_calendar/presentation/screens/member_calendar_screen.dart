import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/pt_calendar/providers/pt_calendar_provider.dart';
import '../../../../features/pt_groups/presentation/screens/group_session_screen.dart';
import '../../../../features/pt_groups/providers/pt_groups_provider.dart';
import '../../../../shared/models/group_model.dart';
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

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sports_gymnastics),
              title: Text(context.l10n.appointmentRequest),
              subtitle: Text(context.l10n.appointmentRequestSub),
              onTap: () {
                Navigator.of(ctx).pop();
                context.push(AppRoutes.booking);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note_outlined),
              title: Text(context.l10n.personalEvent),
              subtitle: Text(context.l10n.addPersonalEventSubtitleMember),
              onTap: () {
                Navigator.of(ctx).pop();
                final sessions =
                    ref.read(memberSessionsProvider(memberId)).valueOrNull ?? [];
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddPersonalEventScreen(
                    memberId: memberId,
                    initialDate: selectedDay,
                    existingSessions: sessions,
                  ),
                ));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalEventsAsync =
        ref.watch(memberPersonalEventsProvider(memberId));
    final sessionsAsync = ref.watch(memberSessionsProvider(memberId));
    final theme = Theme.of(context);

    final personalEvents = personalEventsAsync.valueOrNull ?? [];
    final sessions = sessionsAsync.valueOrNull ?? [];

    // Two-step group session approach:
    // 1) Get all groups the member belongs to
    // 2) For each group, watch its sessions (simple groupId == groupId query)
    // This avoids arrayContains on group_sessions.memberIds and is more robust.
    final memberGroups =
        ref.watch(memberGroupsProvider(memberId)).valueOrNull ?? [];
    final groupSessions = <GroupSession>[];
    for (final group in memberGroups) {
      final sessions2 =
          ref.watch(groupSessionsProvider(group.id)).valueOrNull ?? [];
      groupSessions.addAll(sessions2);
    }

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

    final dayGroupSessions = groupSessions
        .where((s) => isSameDay(s.dateTime, selectedDay) && !s.isCancelled)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.memberCalendarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.l10n.add,
            onPressed: () => _showAddOptions(context, ref),
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
              final hasGroupSession = groupSessions
                  .any((s) => isSameDay(s.dateTime, day) && !s.isCancelled);
              final markers = <Object>[];
              if (hasPersonal) markers.add('personal');
              if (hasSession) markers.add('session');
              if (hasGroupSession) markers.add('group');
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
                        : e == 'group'
                            ? Colors.purple
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
            child: (dayPersonalEvents.isEmpty &&
                    daySessions.isEmpty &&
                    dayGroupSessions.isEmpty)
                ? AppEmpty(
                    message: DateFormat('d MMMM', 'tr').format(selectedDay),
                    subMessage: context.l10n.noEventForDay,
                    icon: Icons.event_note_outlined,
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      ...daySessions.map((s) => _SessionTile(session: s, memberId: memberId)),
                      ...dayGroupSessions.map(
                          (s) => _MemberGroupSessionTile(groupSession: s)),
                      ...dayPersonalEvents.map((e) => _PersonalEventTile(
                          event: e,
                          memberId: memberId,
                          existingSessions: sessions)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  final SessionModel session;
  final String memberId;

  const _SessionTile({required this.session, required this.memberId});

  void _showDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SessionDetailSheet(
        session: session,
        memberId: memberId,
        ref: ref,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeStr = DateFormat('HH:mm').format(session.dateTime);
    final hasPendingRequest =
        session.cancellationRequestedBy != null;
    final statusColor = switch (session.status) {
      SessionStatus.confirmed => Colors.green,
      SessionStatus.pending => Colors.orange,
      _ => Colors.grey,
    };
    final statusLabel = switch (session.status) {
      SessionStatus.confirmed => context.l10n.statusConfirmed,
      SessionStatus.pending => context.l10n.statusPending,
      SessionStatus.completed => context.l10n.statusCompleted,
      _ => '',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: session.status == SessionStatus.confirmed
            ? () => _showDetail(context, ref)
            : null,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.sports_gymnastics,
              color: Colors.green, size: 20),
        ),
        title: Text(
          context.l10n.ptAppointment,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('$timeStr • ${session.durationMinutes} dk'
            '${hasPendingRequest ? ' • ⚠️ İptal Talebi' : ''}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
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

class _SessionDetailSheet extends StatelessWidget {
  final SessionModel session;
  final String memberId;
  final WidgetRef ref;

  const _SessionDetailSheet({
    required this.session,
    required this.memberId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ref.read(sessionRepositoryProvider);
    final timeStr = DateFormat('HH:mm, d MMMM', 'tr').format(session.dateTime);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Text(context.l10n.ptAppointment,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('$timeStr • ${session.durationMinutes} dk',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),

          // Cancellation request section for confirmed sessions
          _MemberCancellationWidget(
            session: session,
            memberId: memberId,
            repo: repo,
          ),
        ],
      ),
    );
  }
}

class _MemberCancellationWidget extends StatelessWidget {
  final SessionModel session;
  final String memberId;
  final SessionRepository repo;

  const _MemberCancellationWidget({
    required this.session,
    required this.memberId,
    required this.repo,
  });

  Future<void> _sendRequest(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.sendCancellationRequest),
        content: Text(context.l10n.cancellationRequestConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: Text(context.l10n.sendCancellationRequest),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repo.requestCancellation(session.id, 'member');
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requested = session.cancellationRequestedBy;

    // PT sent a request → member can Accept or Reject
    if (requested == 'pt') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(context.l10n.ptRequestedCancellation,
                      style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    repo.rejectCancellationRequest(session.id);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error)),
                  child: Text(context.l10n.rejectCancellation),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    repo.acceptCancellationRequest(session.id);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white),
                  child: Text(context.l10n.acceptCancellation),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Member already sent a request
    if (requested == 'member') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_top,
                color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Text(context.l10n.cancellationRequestSent,
                style: const TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    // No pending request
    return OutlinedButton.icon(
      onPressed: () => _sendRequest(context),
      icon: const Icon(Icons.cancel_schedule_send_outlined),
      label: Text(context.l10n.sendCancellationRequest),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: BorderSide(color: AppColors.error),
      ),
    );
  }
}

// ─── Member Group Session Tile ────────────────────────────────────────────────

class _MemberGroupSessionTile extends StatelessWidget {
  final GroupSession groupSession;

  const _MemberGroupSessionTile({required this.groupSession});

  @override
  Widget build(BuildContext context) {
    final s = groupSession;
    final statusColor =
        s.isCompleted ? Colors.green : s.isCancelled ? Colors.red : Colors.purple;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _MemberGroupSessionLoader(groupSession: s),
          ),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.groups, color: Colors.purple, size: 20),
        ),
        title: Text(
          s.groupName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${DateFormat('HH:mm').format(s.dateTime)} • ${s.durationMinutes} dk',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            s.isCompleted
                ? context.l10n.completed
                : s.isCancelled
                    ? context.l10n.cancelled
                    : context.l10n.scheduled,
            style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

/// Loads the GroupModel then opens GroupSessionScreen (read-only for member).
class _MemberGroupSessionLoader extends ConsumerWidget {
  final GroupSession groupSession;

  const _MemberGroupSessionLoader({required this.groupSession});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupByIdProvider(groupSession.groupId));

    return groupAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (group) {
        if (group == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Grup bulunamadı')),
          );
        }
        return GroupSessionScreen(group: group, session: groupSession);
      },
    );
  }
}

// ─── Personal Event Tile ──────────────────────────────────────────────────────

class _PersonalEventTile extends ConsumerWidget {
  final PersonalEventModel event;
  final String memberId;
  final List<SessionModel> existingSessions;

  const _PersonalEventTile({
    required this.event,
    required this.memberId,
    required this.existingSessions,
  });

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
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddPersonalEventScreen(
            memberId: memberId,
            existingSessions: existingSessions,
            eventToEdit: event,
          ),
        )),
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
        title: Text(context.l10n.deleteEventTitle),
        content: Text(context.l10n.deleteEventConfirm(event.title)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(context.l10n.delete)),
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
