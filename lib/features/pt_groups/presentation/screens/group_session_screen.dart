import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/pt_groups/providers/pt_groups_provider.dart';
import '../../../../shared/models/group_model.dart';
import '../../../../shared/widgets/user_avatar.dart';

class GroupSessionScreen extends ConsumerStatefulWidget {
  final GroupModel group;
  final GroupSession? session; // null = create new

  const GroupSessionScreen({super.key, required this.group, this.session});

  @override
  ConsumerState<GroupSessionScreen> createState() =>
      _GroupSessionScreenState();
}

class _GroupSessionScreenState extends ConsumerState<GroupSessionScreen> {
  DateTime _dateTime = DateTime.now().add(const Duration(hours: 1));
  int _duration = 60;
  final _notesCtrl = TextEditingController();
  final _repeatCtrl = TextEditingController(text: '1');
  bool _saving = false;
  int _repeatWeeks = 1; // 1 = no repeat (single session)

  // attendance: {memberId: attended}
  late Map<String, bool> _attendance;

  bool get isNew => widget.session == null;
  bool get isCompleted => widget.session?.isCompleted ?? false;
  bool get isCancelled => widget.session?.isCancelled ?? false;

  @override
  void initState() {
    super.initState();
    if (widget.session != null) {
      final s = widget.session!;
      _dateTime = s.dateTime;
      _duration = s.durationMinutes;
      _notesCtrl.text = s.notes ?? '';
      _attendance = Map.from(s.attendance);
    } else {
      _attendance = {
        for (final id in widget.group.memberIds) id: false,
      };
    }
  }

  void _setRepeat(int value) {
    final clamped = value.clamp(1, 52);
    setState(() => _repeatWeeks = clamped);
    _repeatCtrl.text = '$clamped';
    _repeatCtrl.selection = TextSelection.collapsed(offset: _repeatCtrl.text.length);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _repeatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null || !mounted) return;
    setState(() {
      _dateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _createSession() async {
    setState(() => _saving = true);
    try {
      await ref.read(groupRepositoryProvider).createGroupSession(
            groupId: widget.group.id,
            groupName: widget.group.name,
            ptId: widget.group.ptId,
            dateTime: _dateTime,
            durationMinutes: _duration,
            memberIds: widget.group.memberIds,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
            repeatWeeks: _repeatWeeks,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.error('$e')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _completeSession() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(groupRepositoryProvider)
          .completeGroupSession(
            widget.session!.id,
            widget.session!.groupId,
            widget.session!.ptId,
            _attendance,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.error('$e')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cancelSession() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l10n.cancelSession),
        content: Text(l10n.cancelSessionConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: Text(l10n.confirm,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(groupRepositoryProvider)
          .cancelGroupSession(widget.session!.id);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final groupColor = Color(widget.group.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? l10n.newSession : l10n.sessionDetail),
        backgroundColor: groupColor,
        foregroundColor: Colors.white,
        actions: [
          if (!isCompleted && !isCancelled && !isNew)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              tooltip: l10n.cancelSession,
              onPressed: _saving ? null : _cancelSession,
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).padding.bottom + 24),
        children: [
          // ── Date / time / duration ──────────────────────────────────────
          if (isNew || !isCompleted) ...[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(l10n.dateTime),
                    subtitle: Text(_dateTime.formattedDateTime),
                    trailing: isNew
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: _pickDateTime,
                          )
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(l10n.duration),
                    subtitle: Text('$_duration dk'),
                    trailing: isNew
                        ? DropdownButton<int>(
                            value: _duration,
                            underline: const SizedBox(),
                            items: [30, 45, 60, 75, 90, 120]
                                .map((v) => DropdownMenuItem(
                                    value: v,
                                    child: Text('$v dk')))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _duration = v ?? 60),
                          )
                        : null,
                  ),
                  if (isNew) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.repeat),
                      title: Text(l10n.repeatWeekly),
                      subtitle: Text(_repeatWeeks == 1
                          ? l10n.noRepeat
                          : l10n.repeatCount(_repeatWeeks)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _repeatWeeks > 1
                                ? () => _setRepeat(_repeatWeeks - 1)
                                : null,
                          ),
                          SizedBox(
                            width: 44,
                            child: TextField(
                              controller: _repeatCtrl,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 4),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (v) {
                                final parsed = int.tryParse(v);
                                if (parsed != null && parsed >= 1) {
                                  setState(() =>
                                      _repeatWeeks = parsed.clamp(1, 52));
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _repeatWeeks < 52
                                ? () => _setRepeat(_repeatWeeks + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Attendance ──────────────────────────────────────────────────
          Text(l10n.attendance,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...widget.group.memberIds.map((uid) {
            final name =
                widget.group.memberNames[uid] ?? uid;
            final attended = _attendance[uid] ?? false;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: attended
                      ? Colors.green.withValues(alpha: 0.6)
                      : theme.dividerColor,
                ),
              ),
              child: ListTile(
                leading: UserAvatar(name: name, radius: 20),
                title: Text(name),
                trailing: (isCompleted || isCancelled)
                    ? Icon(
                        attended
                            ? Icons.check_circle
                            : Icons.cancel_outlined,
                        color: attended ? Colors.green : Colors.red,
                      )
                    : Switch(
                        value: attended,
                        activeColor: Colors.green,
                        onChanged: (v) =>
                            setState(() => _attendance[uid] = v),
                      ),
              ),
            );
          }),

          // ── Notes ───────────────────────────────────────────────────────
          const SizedBox(height: 16),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            readOnly: isCompleted || isCancelled,
            decoration: InputDecoration(
              labelText: l10n.notes,
              hintText: l10n.optionalNotes,
              prefixIcon: const Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 24),

          // ── Action button ───────────────────────────────────────────────
          if (!isCompleted && !isCancelled)
            FilledButton.icon(
              onPressed: _saving
                  ? null
                  : (isNew ? _createSession : _completeSession),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(isNew ? Icons.add : Icons.check_circle_outline),
              label: Text(isNew
                  ? l10n.createSession
                  : l10n.markAsCompleted),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor:
                    isNew ? groupColor : Colors.green,
              ),
            ),
          if (isCompleted)
            Chip(
              label: Text(l10n.sessionCompleted,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              avatar: const Icon(Icons.check_circle,
                  color: Colors.white, size: 16),
            ),
          if (isCancelled)
            Chip(
              label: Text(l10n.cancelled,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              avatar: const Icon(Icons.cancel, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }
}
