import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/pt_schedule/providers/work_schedule_provider.dart';
import '../../../../shared/models/work_schedule_model.dart';
import '../../../../shared/widgets/app_loading.dart';

class WorkScheduleScreen extends ConsumerStatefulWidget {
  const WorkScheduleScreen({super.key});

  @override
  ConsumerState<WorkScheduleScreen> createState() => _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends ConsumerState<WorkScheduleScreen> {
  late Map<int, DaySchedule> _days;
  bool _initialized = false;
  bool _saving = false;

  String _quickStart = '09:00';
  String _quickEnd = '18:00';
  String? _quickBreakStart;
  String? _quickBreakEnd;
  bool _quickHasBreak = false;
  final Set<int> _quickSelected = {1, 2, 3, 4, 5};

  Map<int, String> _dayNames(BuildContext context) {
    final l = context.l10n;
    return {
      1: l.dayMon, 2: l.dayTue, 3: l.dayWed,
      4: l.dayThu, 5: l.dayFri, 6: l.daySat, 7: l.daySun,
    };
  }

  Map<int, String> _dayNamesShort(BuildContext context) {
    final l = context.l10n;
    return {
      1: l.dayMonShort, 2: l.dayTueShort, 3: l.dayWedShort,
      4: l.dayThuShort, 5: l.dayFriShort, 6: l.daySatShort, 7: l.daySunShort,
    };
  }

  void _initDays(WorkSchedule? loaded) {
    if (_initialized) return;
    _initialized = true;
    final source = loaded ?? WorkSchedule.defaults();
    _days = {
      for (int i = 1; i <= 7; i++)
        i: source.days[i] ??
            DaySchedule(isActive: i <= 5, startTime: '09:00', endTime: '18:00'),
    };
  }

  Future<void> _save(String ptId) async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      final schedule = WorkSchedule(days: Map.from(_days));
      await ref.read(workScheduleRepositoryProvider).save(ptId, schedule);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.workScheduleSaved),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _applyQuick() {
    setState(() {
      for (final wd in _quickSelected) {
        final existing = _days[wd]!;
        _days[wd] = existing.copyWith(
          isActive: true,
          startTime: _quickStart,
          endTime: _quickEnd,
          breakStart: _quickHasBreak ? _quickBreakStart ?? '12:00' : null,
          breakEnd: _quickHasBreak ? _quickBreakEnd ?? '13:00' : null,
          clearBreak: !_quickHasBreak,
        );
      }
    });
  }

  Future<String?> _pickTime(BuildContext context, String current) async {
    final parts = current.split(':');
    final initial =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  void _editDay(BuildContext context, int weekday) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DayEditSheet(
        dayName: _dayNames(context)[weekday]!,
        schedule: _days[weekday]!,
        onSave: (updated) => setState(() => _days[weekday] = updated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        final scheduleAsync = ref.watch(workScheduleProvider(user.uid));
        return scheduleAsync.when(
          loading: () => const Scaffold(body: AppLoading()),
          error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
          data: (loaded) {
            _initDays(loaded);
            return _buildBody(context, user.uid);
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, String ptId) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final dayNames = _dayNames(context);
    final dayNamesShort = _dayNamesShort(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workingHours),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: () => _save(ptId),
              child: Text(l10n.save),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Quick Apply ───────────────────────────────────────────────
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flash_on, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        l10n.quickApply,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: List.generate(7, (i) {
                      final wd = i + 1;
                      final selected = _quickSelected.contains(wd);
                      return FilterChip(
                        label: Text(dayNamesShort[wd]!),
                        selected: selected,
                        onSelected: (v) => setState(() {
                          if (v) {
                            _quickSelected.add(wd);
                          } else {
                            _quickSelected.remove(wd);
                          }
                        }),
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeTile(
                          label: l10n.startTime,
                          time: _quickStart,
                          onTap: () async {
                            final t = await _pickTime(context, _quickStart);
                            if (t != null) setState(() => _quickStart = t);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TimeTile(
                          label: l10n.endTime,
                          time: _quickEnd,
                          onTap: () async {
                            final t = await _pickTime(context, _quickEnd);
                            if (t != null) setState(() => _quickEnd = t);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Switch(
                        value: _quickHasBreak,
                        onChanged: (v) => setState(() {
                          _quickHasBreak = v;
                          if (v) {
                            _quickBreakStart ??= '12:00';
                            _quickBreakEnd ??= '13:00';
                          }
                        }),
                      ),
                      const SizedBox(width: 4),
                      Text(l10n.breakLabel),
                      if (_quickHasBreak) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TimeTile(
                            label: l10n.breakStart,
                            time: _quickBreakStart ?? '12:00',
                            compact: true,
                            onTap: () async {
                              final t = await _pickTime(context, _quickBreakStart ?? '12:00');
                              if (t != null) setState(() => _quickBreakStart = t);
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _TimeTile(
                            label: l10n.breakEnd,
                            time: _quickBreakEnd ?? '13:00',
                            compact: true,
                            onTap: () async {
                              final t = await _pickTime(context, _quickBreakEnd ?? '13:00');
                              if (t != null) setState(() => _quickBreakEnd = t);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _quickSelected.isEmpty ? null : _applyQuick,
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(l10n.applyToNDays(_quickSelected.length)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Daily Settings ────────────────────────────────────────────
          Text(
            l10n.dailySettings,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(7, (i) {
            final wd = i + 1;
            final day = _days[wd]!;
            return _DayRow(
              dayName: dayNames[wd]!,
              schedule: day,
              onToggle: (v) => setState(() {
                _days[wd] = day.copyWith(isActive: v);
              }),
              onEdit: () => _editDay(context, wd),
            );
          }),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : () => _save(ptId),
            child: Text(l10n.save),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Day row ──────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final String dayName;
  final DaySchedule schedule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _DayRow({
    required this.dayName,
    required this.schedule,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Switch(value: schedule.isActive, onChanged: onToggle),
        title: Text(
          dayName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: schedule.isActive ? null : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: schedule.isActive
            ? Text(
                schedule.hasBreak
                    ? '${schedule.startTime} – ${schedule.endTime}  •  ${l10n.breakLabel}: ${schedule.breakStart}–${schedule.breakEnd}'
                    : '${schedule.startTime} – ${schedule.endTime}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              )
            : Text(
                l10n.closed,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
        trailing: schedule.isActive
            ? IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
              )
            : null,
        onTap: schedule.isActive ? onEdit : null,
      ),
    );
  }
}

// ── Day edit bottom sheet ────────────────────────────────────────────────────

class _DayEditSheet extends StatefulWidget {
  final String dayName;
  final DaySchedule schedule;
  final ValueChanged<DaySchedule> onSave;

  const _DayEditSheet({
    required this.dayName,
    required this.schedule,
    required this.onSave,
  });

  @override
  State<_DayEditSheet> createState() => _DayEditSheetState();
}

class _DayEditSheetState extends State<_DayEditSheet> {
  late String _start;
  late String _end;
  late bool _hasBreak;
  late String _breakStart;
  late String _breakEnd;

  @override
  void initState() {
    super.initState();
    _start = widget.schedule.startTime;
    _end = widget.schedule.endTime;
    _hasBreak = widget.schedule.hasBreak;
    _breakStart = widget.schedule.breakStart ?? '12:00';
    _breakEnd = widget.schedule.breakEnd ?? '13:00';
  }

  Future<String?> _pickTime(String current) async {
    final parts = current.split(':');
    final initial =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.dayName,
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
          Row(
            children: [
              Expanded(
                child: _TimeTile(
                  label: l10n.startTime,
                  time: _start,
                  onTap: () async {
                    final t = await _pickTime(_start);
                    if (t != null) setState(() => _start = t);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeTile(
                  label: l10n.endTime,
                  time: _end,
                  onTap: () async {
                    final t = await _pickTime(_end);
                    if (t != null) setState(() => _end = t);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.breakTimeTitle),
            subtitle: Text(l10n.breakTimeSubtitle),
            value: _hasBreak,
            onChanged: (v) => setState(() => _hasBreak = v),
          ),
          if (_hasBreak) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TimeTile(
                    label: l10n.breakStart,
                    time: _breakStart,
                    onTap: () async {
                      final t = await _pickTime(_breakStart);
                      if (t != null) setState(() => _breakStart = t);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeTile(
                    label: l10n.breakEnd,
                    time: _breakEnd,
                    onTap: () async {
                      final t = await _pickTime(_breakEnd);
                      if (t != null) setState(() => _breakEnd = t);
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(DaySchedule(
                  isActive: widget.schedule.isActive,
                  startTime: _start,
                  endTime: _end,
                  breakStart: _hasBreak ? _breakStart : null,
                  breakEnd: _hasBreak ? _breakEnd : null,
                ));
                Navigator.pop(context);
              },
              child: Text(l10n.done),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Time tile widget ─────────────────────────────────────────────────────────

class _TimeTile extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;
  final bool compact;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 6 : 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    fontSize: compact ? 13 : 15,
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
