import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/models/member_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        // Pre-load members so the sheet gets cached data immediately
        ref.watch(ptMembersProvider(user.uid));
        return _buildCalendar(context, ref, user.uid);
      },
    );
  }

  Widget _buildCalendar(BuildContext context, WidgetRef ref, String ptId) {
    final sessionsAsync = ref.watch(ptSessionsProvider(ptId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSessionSheet(context, ptId),
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (sessions) {
          final sessionsByDay = <DateTime, List<SessionModel>>{};
          for (final s in sessions) {
            final key = DateTime(
                s.dateTime.year, s.dateTime.month, s.dateTime.day);
            sessionsByDay.putIfAbsent(key, () => []).add(s);
          }

          final selectedSessions = sessionsByDay[DateTime(
                  _selectedDay.year,
                  _selectedDay.month,
                  _selectedDay.day)] ??
              [];

          return Column(
            children: [
              TableCalendar<SessionModel>(
                locale: 'tr_TR',
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                calendarFormat: _calendarFormat,
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return sessionsByDay[key] ?? [];
                },
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onFormatChanged: (format) =>
                    setState(() => _calendarFormat = format),
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.3),
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${selectedSessions.length} seans',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: selectedSessions.isEmpty
                    ? AppEmpty(
                        message: 'Bu gün seans yok',
                        icon: Icons.event_available_outlined,
                        action: TextButton.icon(
                          onPressed: () =>
                              _showAddSessionSheet(context, ptId),
                          icon: const Icon(Icons.add),
                          label: const Text('Seans Ekle'),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: selectedSessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _SessionTile(
                          session: selectedSessions[i],
                          onTap: () => context.push(
                              '/pt/calendar/${selectedSessions[i].id}'),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSessionSheet(context, ptId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSessionSheet(BuildContext context, String ptId) {
    final members = ref.read(ptMembersProvider(ptId)).valueOrNull ?? [];
    final repo = ref.read(sessionRepositoryProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddSessionSheet(
        ptId: ptId,
        initialDate: _selectedDay,
        members: members,
        repo: repo,
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
        subtitle: Text('${session.durationMinutes} dk · ${session.dateTime.formattedTime}'),
        trailing: StatusBadge.session(session.status),
      ),
    );
  }
}

class _AddSessionSheet extends StatefulWidget {
  final String ptId;
  final DateTime initialDate;
  final List<MemberProfile> members;
  final SessionRepository repo;

  const _AddSessionSheet({
    required this.ptId,
    required this.initialDate,
    required this.members,
    required this.repo,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
              decoration: const InputDecoration(
                labelText: 'Saat',
                prefixIcon: Icon(Icons.access_time),
              ),
              child: Text(
                '${_selectedDateTime.formattedDate} ${_selectedDateTime.formattedTime}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Süre (dk):', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [30, 45, 60, 90, 120].map(
              (d) => ChoiceChip(
                label: Text('$d'),
                selected: _duration == d,
                onSelected: (_) => setState(() => _duration = d),
                visualDensity: VisualDensity.compact,
              ),
            ).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selectedMemberId == null || _isLoading ? null : _save,
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
