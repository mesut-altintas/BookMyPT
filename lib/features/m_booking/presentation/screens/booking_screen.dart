import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_payment/providers/payment_provider.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../features/m_calendar/providers/invitation_provider.dart';
import '../../../../features/m_calendar/providers/personal_event_provider.dart';
import '../../../../features/pt_calendar/providers/pt_calendar_provider.dart';
import '../../../../features/pt_members/providers/pt_members_provider.dart';
import '../../../../features/pt_schedule/providers/work_schedule_provider.dart';
import '../../../../shared/models/work_schedule_model.dart';
import '../../../../shared/models/personal_event_model.dart';
import '../../../../shared/models/session_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/status_badge.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _buildContent(context, user.uid, user.name, user.ptId);
      },
    );
  }

  Widget _buildContent(BuildContext context, String memberId, String memberName, String? userPtId) {
    final sessionsAsync = ref.watch(memberSessionsProvider(memberId));
    final ptId = userPtId ?? '';
    final ptSessionsAsync = ref.watch(ptSessionsProvider(ptId));
    // Pre-load work schedule so it's available when the sheet opens
    ref.watch(workScheduleProvider(ptId));
    final personalEventsAsync = ref.watch(memberPersonalEventsProvider(memberId));
    final ptPersonalEventsAsync = ref.watch(memberPersonalEventsProvider(ptId));
    final memberDetail = ptId.isNotEmpty
        ? ref
            .watch(ptMemberDetailProvider((ptId: ptId, memberId: memberId)))
            .valueOrNull
        : null;
    final sessionDurationMinutes = memberDetail?.sessionDurationMinutes;
    final remainingByDuration = memberDetail?.remainingSessionsByDuration ?? {};

    // Fallback: derive available durations from completed payments when
    // remainingByDuration is empty (e.g. old data before per-duration tracking)
    final paymentsAsync = ref.watch(memberPaymentsProvider(memberId));
    final fallbackDurations = remainingByDuration.isEmpty
        ? (paymentsAsync.valueOrNull
                ?.where((p) =>
                    p.status == PaymentStatus.completed &&
                    p.sessionDurationMinutes != null)
                .map((p) => p.sessionDurationMinutes!)
                .toSet()
                .toList()
              ?..sort()) ??
            []
        : <int>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myAppointments),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.l10n.requestAppointment,
            onPressed: () {
              final user = ref.read(currentUserProvider).valueOrNull;
              final sessions =
                  ref.read(memberSessionsProvider(memberId)).valueOrNull ?? [];
              _openSheet(context, ref, memberId, user?.name ?? '',
                  user?.ptId ?? '', sessions, sessionDurationMinutes,
                  remainingByDuration, fallbackDurations);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.calendar_month_outlined), text: context.l10n.tabCalendar),
            Tab(icon: const Icon(Icons.history_outlined), text: context.l10n.tabHistory),
          ],
        ),
      ),
      body: sessionsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (sessions) {
          final ptBusy = (ptSessionsAsync.valueOrNull ?? [])
              .where((s) => s.memberId != memberId && s.status != SessionStatus.cancelled)
              .toList();
          final personalEvents = personalEventsAsync.valueOrNull ?? [];
          final ptPersonalEvents = ptPersonalEventsAsync.valueOrNull ?? [];

          final ownByDay = <DateTime, List<SessionModel>>{};
          for (final s in sessions) {
            final key = DateTime(s.dateTime.year, s.dateTime.month, s.dateTime.day);
            ownByDay.putIfAbsent(key, () => []).add(s);
          }
          final ptByDay = <DateTime, List<SessionModel>>{};
          for (final s in ptBusy) {
            final key = DateTime(s.dateTime.year, s.dateTime.month, s.dateTime.day);
            ptByDay.putIfAbsent(key, () => []).add(s);
          }
          final personalByDay = <DateTime, List<PersonalEventModel>>{};
          for (final e in personalEvents) {
            final key = DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day);
            personalByDay.putIfAbsent(key, () => []).add(e);
          }
          final ptPersonalByDay = <DateTime, List<PersonalEventModel>>{};
          for (final e in ptPersonalEvents) {
            final key = DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day);
            ptPersonalByDay.putIfAbsent(key, () => []).add(e);
          }

          final selDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
          final selectedOwn = ownByDay[selDay] ?? [];
          final selectedPt = ptByDay[selDay] ?? [];
          final selectedPersonal = personalByDay[selDay] ?? [];
          final selectedPtPersonal = ptPersonalByDay[selDay] ?? [];

          final allSelected = <Object>[
            ...selectedOwn,
            ...selectedPt,
            ...selectedPtPersonal.map(_PtPersonalBusy.new),
            ...selectedPersonal,
          ]..sort((a, b) {
              DateTime timeOf(Object o) {
                if (o is SessionModel) return o.dateTime;
                if (o is _PtPersonalBusy) return o.event.dateTime;
                return (o as PersonalEventModel).dateTime;
              }
              return timeOf(a).compareTo(timeOf(b));
            });

          return TabBarView(
            controller: _tabController,
            children: [
              // ── Tab 0: Takvim ────────────────────────────────────────────
              Column(
            children: [
              TableCalendar<Object>(
                locale: 'tr_TR',
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                calendarFormat: _calendarFormat,
                onFormatChanged: (f) => setState(() => _calendarFormat = f),
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return [
                    ...(ownByDay[key] ?? []),
                    ...(ptByDay[key] ?? []),
                    ...(ptPersonalByDay[key] ?? []),
                    ...(personalByDay[key] ?? []),
                  ];
                },
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, _) {
                    final key = DateTime(day.year, day.month, day.day);
                    final hasOwn = (ownByDay[key] ?? []).isNotEmpty;
                    final hasPt = (ptByDay[key] ?? []).isNotEmpty ||
                        (ptPersonalByDay[key] ?? []).isNotEmpty;
                    final hasPersonal = (personalByDay[key] ?? []).isNotEmpty;
                    if (!hasOwn && !hasPt && !hasPersonal) return null;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasOwn)
                          Container(
                            width: 6, height: 6,
                            margin: const EdgeInsets.only(top: 4, right: 1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (hasPersonal)
                          Container(
                            width: 6, height: 6,
                            margin: const EdgeInsets.only(top: 4, right: 1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (hasPt)
                          Container(
                            width: 6, height: 6,
                            margin: const EdgeInsets.only(top: 4, left: 1),
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Text(
                      _selectedDay.formattedDate,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.appointmentsCount(selectedOwn.length),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: allSelected.isEmpty
                    ? AppEmpty(
                        message: context.l10n.noDayAppointment,
                        icon: Icons.event_available_outlined,
                        action: TextButton.icon(
                          onPressed: () => _openSheet(context, ref, memberId,
                              memberName, ptId, sessions, sessionDurationMinutes,
                              remainingByDuration, fallbackDurations),
                          icon: const Icon(Icons.add),
                          label: Text(context.l10n.requestAppointment),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: allSelected.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final item = allSelected[i];
                          if (item is _PtPersonalBusy) {
                            return _PtBusyPersonalCard(event: item.event);
                          }
                          if (item is PersonalEventModel) {
                            return _PersonalEventCard(event: item);
                          }
                          final s = item as SessionModel;
                          if (s.memberId == memberId) {
                            return _SessionCard(
                              session: s,
                              onTap: s.status == SessionStatus.pending
                                  ? () => _openEditSheet(
                                        context,
                                        ref,
                                        s,
                                        sessions,
                                        (ptSessionsAsync.valueOrNull ?? [])
                                            .where((p) =>
                                                p.id != s.id &&
                                                p.status != SessionStatus.cancelled)
                                            .toList(),
                                        ptPersonalEvents,
                                        sessionDurationMinutes,
                                        remainingByDuration,
                                        fallbackDurations,
                                      )
                                  : null,
                            );
                          }
                          return _PtBusyCard(session: s);
                        },
                      ),
              ),
            ],
          ),
              // ── Tab 1: Geçmişim ──────────────────────────────────────────
              _HistoryTab(sessions: sessions, memberId: memberId),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openSheet(
    BuildContext context,
    WidgetRef ref,
    String memberId,
    String memberName,
    String ptId,
    List<SessionModel> existingSessions,
    int? sessionDurationMinutes,
    Map<int, int> remainingByDuration,
    List<int> fallbackDurations,
  ) async {
    // Check active status if member has a PT
    if (ptId.isNotEmpty) {
      final memberDetail = ref
          .read(ptMemberDetailProvider((ptId: ptId, memberId: memberId)))
          .valueOrNull;
      if (memberDetail != null && !memberDetail.isActive) {
        if (!context.mounted) return;
        await _showPassiveDialog(context, ref, ptId, memberId, memberName);
        return;
      }
    }
    if (!context.mounted) return;
    final ptPersonalEvents =
        ref.read(memberPersonalEventsProvider(ptId)).valueOrNull ?? [];
    final workSchedule =
        ref.read(workScheduleProvider(ptId)).valueOrNull;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _RequestSessionSheet(
        memberId: memberId,
        memberName: memberName,
        ptId: ptId,
        initialDate: _selectedDay,
        existingSessions: existingSessions,
        ptPersonalEvents: ptPersonalEvents,
        sessionDurationMinutes: sessionDurationMinutes,
        workSchedule: workSchedule,
        remainingByDuration: remainingByDuration,
        fallbackDurations: fallbackDurations,
      ),
    );
  }

  void _openEditSheet(
    BuildContext context,
    WidgetRef ref,
    SessionModel session,
    List<SessionModel> memberSessions,
    List<SessionModel> ptSessions,
    List<PersonalEventModel> ptPersonalEvents,
    int? sessionDurationMinutes,
    Map<int, int> remainingByDuration,
    List<int> fallbackDurations,
  ) {
    final repo = ref.read(sessionRepositoryProvider);
    final memberOther = memberSessions
        .where((s) => s.id != session.id && s.status != SessionStatus.cancelled)
        .toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EditSessionSheet(
        session: session,
        repo: repo,
        memberSessions: memberOther,
        ptSessions: ptSessions,
        ptPersonalEvents: ptPersonalEvents,
        sessionDurationMinutes: sessionDurationMinutes,
        remainingByDuration: remainingByDuration,
        fallbackDurations: fallbackDurations,
      ),
    );
  }

  Future<void> _showPassiveDialog(BuildContext context, WidgetRef ref,
      String ptId, String memberId, String memberName) async {
    final send = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.passiveMemberTitle),
        content: Text(context.l10n.passiveMemberContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.sendRequest),
          ),
        ],
      ),
    );
    if (send != true || !context.mounted) return;
    try {
      // Get PT name
      final ptDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(ptId)
          .get();
      final ptName = (ptDoc.data()?['name'] as String?) ?? '';
      final user = ref.read(currentUserProvider).valueOrNull;
      await ref.read(invitationRepositoryProvider).createActivationRequest(
            ptId: ptId,
            ptName: ptName,
            memberId: memberId,
            memberName: memberName,
            memberEmail: user?.email ?? '',
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.activationRequestSent),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}

class _PtPersonalBusy {
  final PersonalEventModel event;
  const _PtPersonalBusy(this.event);
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback? onTap;

  const _SessionCard({required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                session.dateTime.formattedTime,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          session.dateTime.formattedDayMonth,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(context.l10n.sessionDurationMin(session.durationMinutes)),
        trailing: onTap != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge.session(session.status),
                  const SizedBox(width: 4),
                  Icon(Icons.edit_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ],
              )
            : StatusBadge.session(session.status),
      ),
    );
  }
}

class _PtBusyCard extends StatelessWidget {
  final SessionModel session;
  const _PtBusyCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                session.dateTime.formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          '● ● ●',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 4,
          ),
        ),
        subtitle: Text(
          '${session.durationMinutes} ${context.l10n.minuteShort} — ${context.l10n.ptBusy}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        trailing: Icon(Icons.lock_outline,
            size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _PtBusyPersonalCard extends StatelessWidget {
  final PersonalEventModel event;
  const _PtBusyPersonalCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('HH:mm').format(event.dateTime),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          '● ● ●',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 4,
          ),
        ),
        subtitle: Text(
          '${event.durationMinutes} ${context.l10n.minuteShort} — ${context.l10n.ptBusyPersonal}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        trailing: Icon(Icons.lock_outline,
            size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _PersonalEventCard extends StatelessWidget {
  final PersonalEventModel event;
  const _PersonalEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dMin = event.durationMinutes;
    final durStr = dMin < 60
        ? '$dMin dk'
        : '${dMin ~/ 60} sa${dMin % 60 != 0 ? ' ${dMin % 60} dk' : ''}';
    return Card(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('HH:mm').format(event.dateTime),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        title: Text(event.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$durStr • ${context.l10n.personalActivity}'),
        trailing: Icon(Icons.fitness_center,
            size: 18, color: theme.colorScheme.secondary),
      ),
    );
  }
}

class _RequestSessionSheet extends StatefulWidget {
  final String memberId;
  final String memberName;
  final String ptId;
  final DateTime initialDate;
  final List<SessionModel> existingSessions;
  final List<PersonalEventModel> ptPersonalEvents;
  final int? sessionDurationMinutes;
  final WorkSchedule? workSchedule;
  final Map<int, int> remainingByDuration;
  final List<int> fallbackDurations;

  const _RequestSessionSheet({
    required this.memberId,
    required this.memberName,
    required this.ptId,
    required this.initialDate,
    required this.existingSessions,
    required this.ptPersonalEvents,
    this.sessionDurationMinutes,
    this.workSchedule,
    this.remainingByDuration = const {},
    this.fallbackDurations = const [],
  });

  @override
  State<_RequestSessionSheet> createState() => _RequestSessionSheetState();
}

class _RequestSessionSheetState extends State<_RequestSessionSheet> {
  late DateTime _selectedDateTime;
  int _duration = 60;
  bool _isLoading = false;
  bool _loadingPt = true;
  bool _needsPtLink = false;
  String _ptId = '';
  String _ptName = '';
  String? _ptError;
  List<SessionModel> _ptSessions = [];
  WorkSchedule? _ptWorkSchedule;
  final _ptEmailCtrl = TextEditingController();

  @override
  void dispose() {
    _ptEmailCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Default to 09:00 on the selected day, but never in the past:
    // if that would be past, round up to next full hour + 30 min buffer.
    final base = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
      9,
      0,
    );
    final earliest = DateTime.now().add(const Duration(minutes: 30));
    _selectedDateTime = base.isAfter(earliest) ? base : earliest;
    // Prefer first available package duration, else fallback from payments,
    // else fixed from profile, else default 60
    final availDurations = widget.remainingByDuration.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList()
      ..sort();
    _duration = availDurations.isNotEmpty
        ? availDurations.first
        : widget.fallbackDurations.isNotEmpty
            ? widget.fallbackDurations.first
            : (widget.sessionDurationMinutes ?? 60);
    _findPt();
  }

  Future<void> _findPt() async {
    final ptId = widget.ptId;

    if (ptId.isEmpty) {
      if (mounted) setState(() { _loadingPt = false; _needsPtLink = true; });
      return;
    }

    String ptName = '';
    List<SessionModel> ptSessions = [];

    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(ptId).get(),
        FirebaseFirestore.instance
            .collection('sessions')
            .where('ptId', isEqualTo: ptId)
            .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
            .where('dateTime', isLessThan: Timestamp.fromDate(
                DateTime.now().add(const Duration(days: 90))))
            .get(),
      ]);

      final ptDoc = results[0] as DocumentSnapshot;
      final ptData = ptDoc.data() as Map<String, dynamic>?;
      ptName = ptData?['name'] as String? ?? '';
      ptSessions = (results[1] as QuerySnapshot)
          .docs
          .map((d) => SessionModel.fromFirestore(d))
          .where((s) => s.status != SessionStatus.cancelled)
          .toList();

      // Load work schedule
      final rawSchedule = ptData?['workSchedule'];
      if (rawSchedule is Map) {
        _ptWorkSchedule = WorkSchedule.fromMap(
          Map<String, dynamic>.from(rawSchedule),
        );
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _ptId = ptId;
        _ptName = ptName;
        _ptSessions = ptSessions;
        _loadingPt = false;
      });
    }
  }

  Future<void> _linkPt(String email) async {
    setState(() => _loadingPt = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .where('role', isEqualTo: 'pt')
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        if (mounted) {
          setState(() => _loadingPt = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.ptNotFoundByEmail),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      final ptDoc = snap.docs.first;
      final ptId = ptDoc.id;
      final ptName = ptDoc.data()['name'] as String? ?? '';
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.memberId)
          .update({'ptId': ptId});
      final ptSessionsSnap = await FirebaseFirestore.instance
          .collection('sessions')
          .where('ptId', isEqualTo: ptId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
          .where('dateTime', isLessThan: Timestamp.fromDate(
              DateTime.now().add(const Duration(days: 90))))
          .get();
      final ptSessions = ptSessionsSnap.docs
          .map((d) => SessionModel.fromFirestore(d))
          .where((s) => s.status != SessionStatus.cancelled)
          .toList();
      if (mounted) {
        setState(() {
          _ptId = ptId;
          _ptName = ptName;
          _ptSessions = ptSessions;
          _needsPtLink = false;
          _loadingPt = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingPt = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static String _durationLabel(int minutes) => formatDurationMinutes(minutes);

  Widget _buildDurationPicker(BuildContext context) {
    final theme = Theme.of(context);

    // Case 1: Has package-based duration entries
    final availDurations = widget.remainingByDuration.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList()
      ..sort();

    if (availDurations.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.durationLabel,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availDurations.map((d) {
              final remaining = widget.remainingByDuration[d] ?? 0;
              final isSelected = _duration == d;
              return ChoiceChip(
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_durationLabel(d),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface)),
                    Text('$remaining seans',
                        style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                                : theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _duration = d),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      );
    }

    // Case 2: Fallback durations derived from completed payment history
    if (widget.fallbackDurations.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.durationLabel,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.fallbackDurations.map((d) {
              final isSelected = _duration == d;
              return ChoiceChip(
                label: Text(_durationLabel(d),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface)),
                selected: isSelected,
                onSelected: (_) => setState(() => _duration = d),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      );
    }

    // Case 3: Fixed duration from member profile (legacy)
    if (widget.sessionDurationMinutes != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.timer_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              context.l10n.sessionDurationLabel(widget.sessionDurationMinutes!),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Case 4: No packages, no history — free choice
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.durationLabel,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [30, 45, 60, 90, 120]
              .map((d) => ChoiceChip(
                    label: Text(_durationLabel(d)),
                    selected: _duration == d,
                    onSelected: (_) => setState(() => _duration = d),
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
      ],
    );
  }

  bool _overlaps(SessionModel s) {
    final sEnd = s.dateTime.add(Duration(minutes: s.durationMinutes));
    final newEnd = _selectedDateTime.add(Duration(minutes: _duration));
    return _selectedDateTime.isBefore(sEnd) && newEnd.isAfter(s.dateTime);
  }

  bool _overlapsEvent(PersonalEventModel e) {
    final eEnd = e.dateTime.add(Duration(minutes: e.durationMinutes));
    final newEnd = _selectedDateTime.add(Duration(minutes: _duration));
    return _selectedDateTime.isBefore(eEnd) && newEnd.isAfter(e.dateTime);
  }

  bool get _memberConflict => widget.existingSessions
      .where((s) => s.status != SessionStatus.cancelled)
      .any(_overlaps);

  bool get _ptConflict => _ptSessions.any(_overlaps);

  bool get _ptPersonalConflict =>
      widget.ptPersonalEvents.any(_overlapsEvent);

  /// Returns a Turkish error if the selected time falls outside PT's work schedule.
  String? get _workHoursError {
    final ws = widget.workSchedule ?? _ptWorkSchedule;
    if (ws == null || ws.days.isEmpty) return null;
    return ws.validateSession(_selectedDateTime, _duration);
  }

  /// True when the selected date+time is in the past (or within 5 min).
  bool get _isPast =>
      _selectedDateTime.isBefore(DateTime.now().add(const Duration(minutes: 5)));

  bool get _isConflict => _memberConflict || _ptConflict || _ptPersonalConflict || _workHoursError != null;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final ws = widget.workSchedule ?? _ptWorkSchedule;

    // Date picker — grey out non-working days
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime.isBefore(now) ? now : _selectedDateTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      selectableDayPredicate: ws != null && ws.days.isNotEmpty
          ? (day) => ws.isWorkingDay(day.weekday)
          : null,
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (pickedTime == null || !mounted) return;

    final picked = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    if (picked.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geçmiş bir saat seçildi. Lütfen ileriki bir saat seçin.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    setState(() => _selectedDateTime = picked);
  }

  Future<void> _submit() async {
    if (_ptId.isEmpty || _isConflict || _isPast) return;
    setState(() => _isLoading = true);
    final session = SessionModel(
      id: '',
      ptId: _ptId,
      memberId: widget.memberId,
      memberName: widget.memberName,
      dateTime: _selectedDateTime,
      status: SessionStatus.pending,
      durationMinutes: _duration,
    );
    try {
      await FirebaseFirestore.instance.collection('sessions').add(
            session.toFirestore(),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.requestAppointment,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (_ptName.isNotEmpty)
                    Text(
                      'PT: $_ptName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingPt)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_ptError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                _ptError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else if (_needsPtLink) ...[
            Text(
              context.l10n.findPtEnterEmail,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ptEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: context.l10n.ptEmail,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _linkPt(_ptEmailCtrl.text),
              child: Text(context.l10n.linkPt),
            ),
          ] else ...[
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: context.l10n.dateAndTime,
                  prefixIcon: const Icon(Icons.access_time),
                  errorText: _isPast
                      ? 'Geçmiş bir tarih/saat seçildi'
                      : _memberConflict
                          ? context.l10n.timeConflict
                          : (_ptConflict || _ptPersonalConflict)
                              ? context.l10n.ptNotAvailable
                              : _workHoursError,
                ),
                child: Text(
                  '${_selectedDateTime.formattedDate} ${_selectedDateTime.formattedTime}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildDurationPicker(context),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isConflict || _isPast || _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.requestAppointment),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit Sheet — only for pending sessions
// ---------------------------------------------------------------------------

class _EditSessionSheet extends StatefulWidget {
  final SessionModel session;
  final SessionRepository repo;
  final List<SessionModel> memberSessions;   // member's other sessions (excl. current)
  final List<SessionModel> ptSessions;       // PT's other sessions (excl. current)
  final List<PersonalEventModel> ptPersonalEvents;
  final int? sessionDurationMinutes;
  final Map<int, int> remainingByDuration;
  final List<int> fallbackDurations;

  const _EditSessionSheet({
    required this.session,
    required this.repo,
    required this.memberSessions,
    required this.ptSessions,
    required this.ptPersonalEvents,
    this.sessionDurationMinutes,
    this.remainingByDuration = const {},
    this.fallbackDurations = const [],
  });

  @override
  State<_EditSessionSheet> createState() => _EditSessionSheetState();
}

class _EditSessionSheetState extends State<_EditSessionSheet> {
  late DateTime _selectedDateTime;
  late int _duration;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.session.dateTime;
    _duration = widget.sessionDurationMinutes ?? widget.session.durationMinutes;
  }

  bool _overlapsSession(SessionModel s) {
    if (s.status == SessionStatus.cancelled) return false;
    final sEnd = s.dateTime.add(Duration(minutes: s.durationMinutes));
    final newEnd = _selectedDateTime.add(Duration(minutes: _duration));
    return _selectedDateTime.isBefore(sEnd) && newEnd.isAfter(s.dateTime);
  }

  bool _overlapsEvent(PersonalEventModel e) {
    final eEnd = e.dateTime.add(Duration(minutes: e.durationMinutes));
    final newEnd = _selectedDateTime.add(Duration(minutes: _duration));
    return _selectedDateTime.isBefore(eEnd) && newEnd.isAfter(e.dateTime);
  }

  bool get _memberConflict => widget.memberSessions.any(_overlapsSession);
  bool get _ptConflict => widget.ptSessions.any(_overlapsSession);
  bool get _ptPersonalConflict => widget.ptPersonalEvents.any(_overlapsEvent);
  bool get _isConflict => _memberConflict || _ptConflict || _ptPersonalConflict;
  bool get _isPast =>
      _selectedDateTime.isBefore(DateTime.now().add(const Duration(minutes: 5)));

  bool get _unchanged =>
      _selectedDateTime == widget.session.dateTime &&
      _duration == widget.session.durationMinutes;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime.isBefore(now) ? now : _selectedDateTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null || !mounted) return;
    final picked = DateTime(
      pickedDate.year, pickedDate.month, pickedDate.day,
      pickedTime.hour, pickedTime.minute,
    );
    if (picked.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geçmiş bir saat seçildi. Lütfen ileriki bir saat seçin.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    setState(() => _selectedDateTime = picked);
  }

  Widget _buildEditDurationPicker(BuildContext context) {
    final theme = Theme.of(context);
    final availDurations = widget.remainingByDuration.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList()
      ..sort();

    if (availDurations.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.durationLabel,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availDurations.map((d) {
              final remaining = widget.remainingByDuration[d] ?? 0;
              final isSelected = _duration == d;
              return ChoiceChip(
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_durationLabel(d),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface)),
                    Text('$remaining seans',
                        style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                                : theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _duration = d),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      );
    }

    // Case 2: Fallback durations derived from completed payment history
    if (widget.fallbackDurations.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.durationLabel,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.fallbackDurations.map((d) {
              final isSelected = _duration == d;
              return ChoiceChip(
                label: Text(_durationLabel(d),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface)),
                selected: isSelected,
                onSelected: (_) => setState(() => _duration = d),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      );
    }

    // Case 3: Fixed duration from member profile (legacy)
    if (widget.sessionDurationMinutes != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.timer_outlined,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              context.l10n.sessionDurationLabel(widget.sessionDurationMinutes!),
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    // Case 4: No packages, no history — free choice
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.durationLabel,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [30, 45, 60, 90, 120]
              .map((d) => ChoiceChip(
                    label: Text(_durationLabel(d)),
                    selected: _duration == d,
                    onSelected: (_) => setState(() => _duration = d),
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
      ],
    );
  }

  static String _durationLabel(int minutes) => formatDurationMinutes(minutes);

  Future<void> _save() async {
    if (_isConflict || _isPast || _unchanged) return;
    setState(() => _isLoading = true);
    try {
      await widget.repo.updateSession(widget.session.id, {
        'dateTime': Timestamp.fromDate(_selectedDateTime),
        'durationMinutes': _duration,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.editAppointment,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    context.l10n.onlyPendingCanEdit,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: context.l10n.dateAndTime,
                prefixIcon: const Icon(Icons.access_time),
                errorText: _isPast
                    ? 'Geçmiş bir tarih/saat seçildi'
                    : _memberConflict
                        ? context.l10n.timeConflict
                        : (_ptConflict || _ptPersonalConflict)
                            ? context.l10n.ptNotAvailable
                            : null,
              ),
              child: Text(
                '${_selectedDateTime.formattedDate} ${_selectedDateTime.formattedTime}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildEditDurationPicker(context),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isConflict || _isPast || _unchanged || _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.update),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Geçmişim Tab
// ---------------------------------------------------------------------------

class _HistoryTab extends StatelessWidget {
  final List<SessionModel> sessions;
  final String memberId;

  const _HistoryTab({required this.sessions, required this.memberId});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = Theme.of(context);

    final upcoming = sessions
        .where((s) =>
            s.status == SessionStatus.confirmed && s.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final completed = sessions
        .where((s) => s.status == SessionStatus.completed)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final totalMinutes =
        completed.fold(0, (sum, s) => sum + s.durationMinutes);
    final totalHours = totalMinutes ~/ 60;
    final remainMins = totalMinutes % 60;
    final durationStr = totalHours > 0
        ? '$totalHours sa${remainMins > 0 ? ' $remainMins dk' : ''}'
        : '$totalMinutes dk';

    if (upcoming.isEmpty && completed.isEmpty) {
      return AppEmpty(
        message: context.l10n.noCompletedSessions,
        subMessage: context.l10n.noCompletedSessionsSub,
        icon: Icons.fitness_center_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Özet Kart ────────────────────────────────────────────────────
        Card(
          color: theme.colorScheme.primaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    label: context.l10n.completedCount,
                    value: '${completed.length}',
                    unit: context.l10n.sessions,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _StatCell(
                    label: context.l10n.totalDuration,
                    value: durationStr,
                    unit: '',
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Yaklaşan Onaylı Seanslar ─────────────────────────────────────
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 20),
          _HistorySectionHeader(
            title: context.l10n.upcomingMySessions,
            icon: Icons.event_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          ...upcoming.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _HistorySessionCard(session: s),
              )),
        ],

        // ── Tamamlanan Seanslar ───────────────────────────────────────────
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 20),
          _HistorySectionHeader(
            title: context.l10n.completedSessions,
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          ...completed.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _HistorySessionCard(session: s),
              )),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatCell({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                      fontSize: 13, color: color.withValues(alpha: 0.7)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistorySectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _HistorySectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _HistorySessionCard extends StatelessWidget {
  final SessionModel session;

  const _HistorySessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = session.status == SessionStatus.completed;
    final color = isCompleted ? Colors.green : theme.colorScheme.primary;

    return Card(
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isCompleted ? Icons.fitness_center : Icons.event_outlined,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          DateFormat('d MMMM y, EEEE', 'tr').format(session.dateTime),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          '${DateFormat('HH:mm').format(session.dateTime)} • ${session.durationMinutes} dk',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: StatusBadge.session(session.status),
      ),
    );
  }
}
