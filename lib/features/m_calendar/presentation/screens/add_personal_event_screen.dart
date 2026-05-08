import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/personal_event_model.dart';
import '../../../../shared/models/session_model.dart';
import '../../providers/personal_event_provider.dart';

class AddPersonalEventScreen extends ConsumerStatefulWidget {
  final String memberId;
  final DateTime? initialDate;
  final List<SessionModel> existingSessions;
  final PersonalEventModel? eventToEdit;

  const AddPersonalEventScreen({
    super.key,
    required this.memberId,
    this.initialDate,
    this.existingSessions = const [],
    this.eventToEdit,
  });

  @override
  ConsumerState<AddPersonalEventScreen> createState() =>
      _AddPersonalEventScreenState();
}

class _AddPersonalEventScreenState
    extends ConsumerState<AddPersonalEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _durationMinutes = 60;

  bool get _isEditing => widget.eventToEdit != null;

  static const _durations = [30, 45, 60, 90, 120];

  DateTime get _selectedDt => DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute,
      );

  bool _overlapsSession(SessionModel s) {
    if (s.status == SessionStatus.cancelled) return false;
    final sEnd = s.dateTime.add(Duration(minutes: s.durationMinutes));
    final newEnd = _selectedDt.add(Duration(minutes: _durationMinutes));
    return _selectedDt.isBefore(sEnd) && newEnd.isAfter(s.dateTime);
  }

  bool get _hasConflict =>
      widget.existingSessions.any(_overlapsSession);

  @override
  void initState() {
    super.initState();
    final edit = widget.eventToEdit;
    if (edit != null) {
      _titleCtrl.text = edit.title;
      _notesCtrl.text = edit.notes ?? '';
      _selectedDate = DateTime(edit.dateTime.year, edit.dateTime.month, edit.dateTime.day);
      _selectedTime = TimeOfDay(hour: edit.dateTime.hour, minute: edit.dateTime.minute);
      _durationMinutes = edit.durationMinutes;
    } else {
      final base = widget.initialDate ?? DateTime.now();
      _selectedDate = DateTime(base.year, base.month, base.day);
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _hasConflict) return;
    setState(() => _loading = true);

    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      final repo = ref.read(personalEventRepositoryProvider);
      if (_isEditing) {
        await repo.updateEvent(PersonalEventModel(
          id: widget.eventToEdit!.id,
          memberId: widget.eventToEdit!.memberId,
          title: _titleCtrl.text.trim(),
          dateTime: dt,
          durationMinutes: _durationMinutes,
          notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
          createdAt: widget.eventToEdit!.createdAt,
        ));
      } else {
        await repo.createEvent(
          PersonalEventModel(
            id: '',
            memberId: widget.memberId,
            title: _titleCtrl.text.trim(),
            dateTime: dt,
            durationMinutes: _durationMinutes,
            notes: _notesCtrl.text.trim().isNotEmpty
                ? _notesCtrl.text.trim()
                : null,
            createdAt: DateTime.now(),
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        DateFormat('d MMMM yyyy', 'tr').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Etkinliği Düzenle' : 'Etkinlik Ekle'),
        actions: [
          TextButton(
            onPressed: (_loading || _hasConflict) ? null : _save,
            child: const Text('Kaydet'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Başlık gerekli' : null,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        hintText: 'Antrenman, Koşu...',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Tarih ve Saat',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(dateStr),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(timeStr),
                            style: _hasConflict
                                ? OutlinedButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.error,
                                    side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    if (_hasConflict) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Bu saatte çakışan seans var',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text('Süre',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _durations.map((d) {
                        final label =
                            d < 60 ? '$d dk' : '${d ~/ 60} sa${d % 60 != 0 ? ' ${d % 60} dk' : ''}';
                        return ChoiceChip(
                          label: Text(label),
                          selected: _durationMinutes == d,
                          onSelected: (_) =>
                              setState(() => _durationMinutes = d),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notlar (İsteğe bağlı)',
                        prefixIcon: Icon(Icons.notes_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
