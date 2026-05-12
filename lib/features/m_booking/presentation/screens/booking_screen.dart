import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_calendar/providers/invitation_provider.dart';
import '../../../../features/m_calendar/providers/personal_event_provider.dart';
import '../../../../features/pt_calendar/providers/pt_calendar_provider.dart';
import '../../../../features/pt_members/providers/pt_members_provider.dart';
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
    final personalEventsAsync = ref.watch(memberPersonalEventsProvider(memberId));
    final ptPersonalEventsAsync = ref.watch(memberPersonalEventsProvider(ptId));
    final sessionDurationMinutes = ptId.isNotEmpty
        ? ref
            .watch(ptMemberDetailProvider((ptId: ptId, memberId: memberId)))
            .valueOrNull
            ?.sessionDurationMinutes
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevularım'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Randevu Talep Et',
            onPressed: () {
              final user = ref.read(currentUserProvider).valueOrNull;
              final sessions =
                  ref.read(memberSessionsProvider(memberId)).valueOrNull ?? [];
              _openSheet(context, ref, memberId, user?.name ?? '',
                  user?.ptId ?? '', sessions, sessionDurationMinutes);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Takvim'),
            Tab(icon: Icon(Icons.history_outlined), text: 'Geçmişim'),
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
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
                      '${selectedOwn.length} randevum',
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
                        message: 'Bu gün randevu yok',
                        icon: Icons.event_available_outlined,
                        action: TextButton.icon(
                          onPressed: () => _openSheet(context, ref, memberId,
                              memberName, ptId, sessions, sessionDurationMinutes),
                          icon: const Icon(Icons.add),
                          label: const Text('Randevu Talep Et'),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RequestSessionSheet(
        memberId: memberId,
        memberName: memberName,
        ptId: ptId,
        initialDate: _selectedDay,
        existingSessions: existingSessions,
        ptPersonalEvents: ptPersonalEvents,
        sessionDurationMinutes: sessionDurationMinutes,
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
  ) {
    final repo = ref.read(sessionRepositoryProvider);
    final memberOther = memberSessions
        .where((s) => s.id != session.id && s.status != SessionStatus.cancelled)
        .toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditSessionSheet(
        session: session,
        repo: repo,
        memberSessions: memberOther,
        ptSessions: ptSessions,
        ptPersonalEvents: ptPersonalEvents,
        sessionDurationMinutes: sessionDurationMinutes,
      ),
    );
  }

  Future<void> _showPassiveDialog(BuildContext context, WidgetRef ref,
      String ptId, String memberId, String memberName) async {
    final send = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Pasif Üye'),
        content: const Text(
            'Randevu alabilmek için aktif olmanız gerekiyor. Eğitmeninize aktivasyon isteği göndermek ister misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('İstek Gönder'),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Aktivasyon isteği gönderildi'),
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
        subtitle: Text('${session.durationMinutes} dk seans'),
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
            color: Colors.grey.withOpacity(0.2),
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
          '${session.durationMinutes} dk — PT dolu',
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
            color: Colors.grey.withOpacity(0.2),
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
          '${event.durationMinutes} dk — PT meşgul',
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
      color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
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
        subtitle: Text('$durStr • Kişisel etkinlik'),
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

  const _RequestSessionSheet({
    required this.memberId,
    required this.memberName,
    required this.ptId,
    required this.initialDate,
    required this.existingSessions,
    required this.ptPersonalEvents,
    this.sessionDurationMinutes,
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
  final _ptEmailCtrl = TextEditingController();

  @override
  void dispose() {
    _ptEmailCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
      9,
      0,
    );
    _duration = widget.sessionDurationMinutes ?? 60;
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
      ptName = (ptDoc.data() as Map<String, dynamic>?)?['name'] as String? ?? '';
      ptSessions = (results[1] as QuerySnapshot)
          .docs
          .map((d) => SessionModel.fromFirestore(d))
          .where((s) => s.status != SessionStatus.cancelled)
          .toList();
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
            const SnackBar(
              content: Text('Bu e-posta ile kayıtlı PT bulunamadı'),
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

  bool get _isConflict => _memberConflict || _ptConflict || _ptPersonalConflict;

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null || !mounted) return;
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (_ptId.isEmpty || _isConflict) return;
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
                    'Randevu Talep Et',
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
              'PT\'nizi bulmak için e-posta adresini girin',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ptEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'PT E-posta',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _linkPt(_ptEmailCtrl.text),
              child: const Text('PT\'yi Bağla'),
            ),
          ] else ...[
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tarih ve Saat',
                  prefixIcon: const Icon(Icons.access_time),
                  errorText: _memberConflict
                      ? 'Bu saatte zaten randevunuz var'
                      : (_ptConflict || _ptPersonalConflict)
                          ? 'PT bu saatte müsait değil'
                          : null,
                ),
                child: Text(
                  '${_selectedDateTime.formattedDate} ${_selectedDateTime.formattedTime}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (widget.sessionDurationMinutes != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'Seans süresi: ${widget.sessionDurationMinutes} dk',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              const Text('Süre (dk):',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [30, 45, 60, 90, 120]
                    .map((d) => ChoiceChip(
                          label: Text('$d'),
                          selected: _duration == d,
                          onSelected: (_) => setState(() => _duration = d),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isConflict || _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Randevu Talep Et'),
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

  const _EditSessionSheet({
    required this.session,
    required this.repo,
    required this.memberSessions,
    required this.ptSessions,
    required this.ptPersonalEvents,
    this.sessionDurationMinutes,
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

  bool get _unchanged =>
      _selectedDateTime == widget.session.dateTime &&
      _duration == widget.session.durationMinutes;

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null || !mounted) return;
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year, pickedDate.month, pickedDate.day,
        pickedTime.hour, pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_isConflict || _unchanged) return;
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
                    'Randevu Düzenle',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Sadece bekleyen talepler düzenlenebilir',
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
                labelText: 'Tarih ve Saat',
                prefixIcon: const Icon(Icons.access_time),
                errorText: _memberConflict
                    ? 'Bu saatte zaten randevunuz var'
                    : (_ptConflict || _ptPersonalConflict)
                        ? 'PT bu saatte müsait değil'
                        : null,
              ),
              child: Text(
                '${_selectedDateTime.formattedDate} ${_selectedDateTime.formattedTime}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.sessionDurationMinutes != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Seans süresi: ${widget.sessionDurationMinutes} dk',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            const Text('Süre (dk):', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [30, 45, 60, 90, 120]
                  .map((d) => ChoiceChip(
                        label: Text('$d'),
                        selected: _duration == d,
                        onSelected: (_) => setState(() => _duration = d),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isConflict || _unchanged || _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Güncelle'),
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
      return const AppEmpty(
        message: 'Henüz tamamlanan seans yok',
        subMessage: 'Onaylanan seanslarınız tamamlandıkça burada görünecek',
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
                    label: 'Tamamlanan',
                    value: '${completed.length}',
                    unit: 'seans',
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
                    label: 'Toplam süre',
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
            title: 'Yaklaşan Seanslarım',
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
            title: 'Tamamlanan Seanslar',
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
