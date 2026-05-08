import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_calendar/presentation/screens/add_personal_event_screen.dart';
import '../../../../features/m_calendar/providers/personal_event_provider.dart';
import '../../../../shared/models/member_model.dart';
import '../../../../shared/models/personal_event_model.dart';
import '../../../../shared/models/session_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../pt_calendar/providers/pt_calendar_provider.dart';
import '../../../pt_members/providers/pt_members_provider.dart';

class PtCalendarScreen extends ConsumerStatefulWidget {
  const PtCalendarScreen({super.key});

  @override
  ConsumerState<PtCalendarScreen> createState() => _PtCalendarScreenState();
}

class _PtCalendarScreenState extends ConsumerState<PtCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        ref.watch(ptMembersProvider(user.uid));
        return _buildCalendar(context, ref, user.uid);
      },
    );
  }

  Widget _buildCalendar(BuildContext context, WidgetRef ref, String ptId) {
    final sessionsAsync = ref.watch(ptSessionsProvider(ptId));
    final personalEventsAsync = ref.watch(memberPersonalEventsProvider(ptId));
    final theme = Theme.of(context);

    final sessions = sessionsAsync.valueOrNull ?? [];
    final personalEvents = personalEventsAsync.valueOrNull ?? [];

    final selectedSessions = sessions
        .where((s) =>
            _isSameDay(s.dateTime, _selectedDay) &&
            s.status != SessionStatus.cancelled)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final selectedPersonalEvents = personalEvents
        .where((e) => _isSameDay(e.dateTime, _selectedDay))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ekle',
            onPressed: () => _showAddOptions(context, ptId),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Object>(
            locale: 'tr_TR',
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(titleCentered: true),
            eventLoader: (day) {
              final hasSession = sessions.any((s) =>
                  _isSameDay(s.dateTime, day) &&
                  s.status != SessionStatus.cancelled);
              final hasPersonal =
                  personalEvents.any((e) => _isSameDay(e.dateTime, day));
              return [
                if (hasSession) 'session',
                if (hasPersonal) 'personal',
              ];
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
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    );
                  }).toList(),
                );
              },
            ),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onFormatChanged: (format) =>
                setState(() => _calendarFormat = format),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              todayTextStyle:
                  TextStyle(color: theme.colorScheme.onPrimaryContainer),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
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
                if (selectedSessions.isNotEmpty)
                  Text(
                    '${selectedSessions.length} seans',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                if (selectedSessions.isNotEmpty &&
                    selectedPersonalEvents.isNotEmpty)
                  const Text(' · '),
                if (selectedPersonalEvents.isNotEmpty)
                  Text(
                    '${selectedPersonalEvents.length} etkinlik',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: (selectedSessions.isEmpty && selectedPersonalEvents.isEmpty)
                ? AppEmpty(
                    message: 'Bu gün etkinlik yok',
                    icon: Icons.event_available_outlined,
                    action: TextButton.icon(
                      onPressed: () => _showAddOptions(context, ptId),
                      icon: const Icon(Icons.add),
                      label: const Text('Ekle'),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...selectedSessions.map((s) => _SessionTile(
                            session: s,
                            onTap: () =>
                                context.push('/pt/calendar/${s.id}'),
                          )),
                      ...selectedPersonalEvents.map((e) =>
                          _PersonalEventTile(
                            event: e,
                            ptId: ptId,
                            existingSessions: sessions
                                .where((s) => s.status != SessionStatus.cancelled)
                                .toList(),
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context, String ptId) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sports_gymnastics),
              title: const Text('Seans Ekle'),
              subtitle: const Text('Üye ile antrenman seansı planla'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showAddSessionSheet(context, ptId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note_outlined),
              title: const Text('Kişisel Etkinlik'),
              subtitle: const Text('Antrenman, not veya hatırlatıcı ekle'),
              onTap: () {
                Navigator.of(ctx).pop();
                final sessions =
                    ref.read(ptSessionsProvider(ptId)).valueOrNull ?? [];
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddPersonalEventScreen(
                    memberId: ptId,
                    initialDate: _selectedDay,
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

  void _showAddSessionSheet(BuildContext context, String ptId) {
    final members = ref.read(ptMembersProvider(ptId)).valueOrNull ?? [];
    final repo = ref.read(sessionRepositoryProvider);
    final existingSessions =
        ref.read(ptSessionsProvider(ptId)).valueOrNull ?? [];
    final ptPersonalEvents =
        ref.read(memberPersonalEventsProvider(ptId)).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      builder: (_) => _AddSessionSheet(
        ptId: ptId,
        initialDate: _selectedDay,
        members: members,
        repo: repo,
        existingSessions: existingSessions,
        ptPersonalEvents: ptPersonalEvents,
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onTap;

  const _SessionTile({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                session.dateTime.formattedTime,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          session.memberName.isNotEmpty ? session.memberName : 'İsimsiz Üye',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
            '${session.durationMinutes} dk · ${session.dateTime.formattedTime}'),
        trailing: StatusBadge.session(session.status),
      ),
    );
  }
}

class _PersonalEventTile extends ConsumerWidget {
  final PersonalEventModel event;
  final String ptId;
  final List<SessionModel> existingSessions;

  const _PersonalEventTile({
    required this.event,
    required this.ptId,
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
            memberId: ptId,
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
        title:
            Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$timeStr • $durStr'),
        trailing: IconButton(
          icon:
              Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
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
        content:
            Text('"${event.title}" etkinliğini silmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(personalEventRepositoryProvider).deleteEvent(event.id);
    }
  }
}

class _AddSessionSheet extends StatefulWidget {
  final String ptId;
  final DateTime initialDate;
  final List<MemberProfile> members;
  final SessionRepository repo;
  final List<SessionModel> existingSessions;
  final List<PersonalEventModel> ptPersonalEvents;

  const _AddSessionSheet({
    required this.ptId,
    required this.initialDate,
    required this.members,
    required this.repo,
    required this.existingSessions,
    required this.ptPersonalEvents,
  });

  @override
  State<_AddSessionSheet> createState() => _AddSessionSheetState();
}

class _AddSessionSheetState extends State<_AddSessionSheet> {
  late DateTime _selectedDateTime;
  String? _selectedMemberId;
  String? _selectedMemberName;
  int _duration = 60;
  bool _isLoading = false;

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

  bool get _hasConflict =>
      widget.existingSessions.any(_overlapsSession) ||
      widget.ptPersonalEvents.any(_overlapsEvent);

  Future<void> _save() async {
    if (_selectedMemberId == null) return;
    setState(() => _isLoading = true);
    final session = SessionModel(
      id: '',
      ptId: widget.ptId,
      memberId: _selectedMemberId!,
      memberName: _selectedMemberName!,
      dateTime: _selectedDateTime,
      status: SessionStatus.pending,
      durationMinutes: _duration,
    );
    try {
      await widget.repo.createSession(session);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.members;

    return Padding(
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
              Text(
                'Seans Ekle',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          members.isEmpty
              ? const Text('Henüz üye yok')
              : DropdownButtonFormField<String>(
                  value: _selectedMemberId,
                  hint: const Text('Üye Seç'),
                  items: members
                      .map((m) => DropdownMenuItem<String>(
                            value: m.memberId,
                            child: Text(m.name.isNotEmpty ? m.name : m.email),
                            onTap: () => _selectedMemberName =
                                m.name.isNotEmpty ? m.name : m.email,
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedMemberId = v),
                  decoration: const InputDecoration(labelText: 'Üye'),
                ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickTime,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Saat',
                prefixIcon: const Icon(Icons.access_time),
                errorText: _hasConflict ? 'Bu saatte çakışan etkinlik var' : null,
              ),
              child: Text(
                '${_selectedDateTime.formattedDate} ${_selectedDateTime.formattedTime}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Süre (dk):',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [30, 45, 60, 90, 120]
                .map(
                  (d) => ChoiceChip(
                    label: Text('$d'),
                    selected: _duration == d,
                    onSelected: (_) => setState(() => _duration = d),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selectedMemberId == null || _isLoading || _hasConflict
                ? null
                : _save,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Seans Oluştur'),
          ),
        ],
      ),
    );
  }
}
