import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/models/program_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../pt_members/providers/pt_members_provider.dart';
import '../../../pt_programs/providers/pt_programs_provider.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  final ProgramModel? initialProgram;
  final String? initialMemberId;
  final String? initialMemberName;

  const CreateProgramScreen({
    super.key,
    this.initialProgram,
    this.initialMemberId,
    this.initialMemberName,
  });

  @override
  ConsumerState<CreateProgramScreen> createState() =>
      _CreateProgramScreenState();
}

class _CreateProgramScreenState extends ConsumerState<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedMemberId;
  String? _selectedMemberName;
  int _weeksCount = 4;
  bool _isLoading = false;
  late List<WorkoutWeek> _weeks;

  bool get _isEditing => widget.initialProgram != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.initialProgram!;
      _titleCtrl.text = p.title;
      _descCtrl.text = p.description ?? '';
      _selectedMemberId = p.memberId;
      _selectedMemberName = p.memberName;
      _weeksCount = p.weeks.length;
      _weeks = List.from(p.weeks);
    } else {
      // Pre-select member if navigated from member detail
      if (widget.initialMemberId != null) {
        _selectedMemberId = widget.initialMemberId;
        _selectedMemberName = widget.initialMemberName;
      }
      _initWeeks();
    }
  }

  static const _dayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

  void _initWeeks() {
    _weeks = List.generate(
      _weeksCount,
      (wi) => WorkoutWeek(
        weekNumber: wi + 1,
        days: List.generate(
          7,
          (di) => WorkoutDay(
            dayName: _dayNames[di],
            exercises: [],
            isRestDay: di >= 5,
          ),
        ),
      ),
    );
  }

  void _addWeek() {
    setState(() {
      _weeksCount++;
      _weeks.add(WorkoutWeek(
        weekNumber: _weeksCount,
        days: List.generate(7, (di) => WorkoutDay(
          dayName: _dayNames[di],
          exercises: [],
          isRestDay: di >= 5,
        )),
      ));
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectMemberSnack)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final program = ProgramModel(
      id: '',
      ptId: user.uid,
      memberId: _selectedMemberId!,
      memberName: _selectedMemberName!,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isNotEmpty
          ? _descCtrl.text.trim()
          : null,
      weeks: _weeks,
      createdAt: DateTime.now(),
    );

    try {
      final repo = ref.read(programRepositoryProvider);
      if (_isEditing) {
        final data = program.toFirestore()..remove('createdAt');
        await repo.updateProgram(widget.initialProgram!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.programUpdated)),
          );
          context.pop();
        }
      } else {
        await repo.createProgram(program);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.programCreated)),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.error('$e')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addExercise(int weekIndex, int dayIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddExerciseSheet(
        onAdd: (exercise) {
          setState(() {
            final updatedDays = List<WorkoutDay>.from(_weeks[weekIndex].days);
            final day = updatedDays[dayIndex];
            updatedDays[dayIndex] = WorkoutDay(
              dayName: day.dayName,
              exercises: [...day.exercises, exercise],
              isRestDay: day.isRestDay,
            );
            _weeks[weekIndex] = WorkoutWeek(
              weekNumber: _weeks[weekIndex].weekNumber,
              days: updatedDays,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: AppLoading(message: context.l10n.saving));

    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        final membersAsync = ref.watch(ptMembersProvider(user.uid));

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? context.l10n.editProgram : context.l10n.createProgram),
            actions: [
              TextButton(onPressed: _save, child: Text(context.l10n.save)),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  validator: (v) => Validators.required(v, context.l10n.programName),
                  decoration: InputDecoration(
                    labelText: context.l10n.programName,
                    hintText: context.l10n.programNameHint,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.l10n.descriptionOptional,
                    hintText: context.l10n.programDescriptionHint,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                membersAsync.when(
                  loading: () => const AppLoading(size: 24),
                  error: (_, __) => Text(context.l10n.membersLoadFailed),
                  data: (members) => DropdownButtonFormField<String>(
                    value: _selectedMemberId,
                    hint: Text(context.l10n.selectMember),
                    items: members
                        .map((m) => DropdownMenuItem(
                              value: m.memberId,
                              child: Text(m.name),
                              onTap: () => _selectedMemberName = m.name,
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMemberId = v),
                    decoration: InputDecoration(
                      labelText: context.l10n.member,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(context.l10n.weekCountLabel,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        if (_weeksCount > 1) {
                          setState(() {
                            _weeksCount--;
                            _weeks.removeLast();
                          });
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$_weeksCount',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: _weeksCount < 12 ? _addWeek : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                ...List.generate(_weeks.length, (wi) {
                  final week = _weeks[wi];
                  return _WeekSection(
                    week: week,
                    onAddExercise: (di) => _addExercise(wi, di),
                    onRemoveExercise: (di, ei) {
                      setState(() {
                        final updatedDays = List<WorkoutDay>.from(week.days);
                        final day = updatedDays[di];
                        final exercises = List<ExerciseModel>.from(day.exercises);
                        exercises.removeAt(ei);
                        updatedDays[di] = WorkoutDay(
                          dayName: day.dayName,
                          exercises: exercises,
                          isRestDay: day.isRestDay,
                        );
                        _weeks[wi] = WorkoutWeek(
                          weekNumber: week.weekNumber,
                          days: updatedDays,
                        );
                      });
                    },
                    onToggleRestDay: (di) {
                      setState(() {
                        final updatedDays = List<WorkoutDay>.from(week.days);
                        final day = updatedDays[di];
                        updatedDays[di] = WorkoutDay(
                          dayName: day.dayName,
                          exercises: day.exercises,
                          isRestDay: !day.isRestDay,
                        );
                        _weeks[wi] = WorkoutWeek(
                          weekNumber: week.weekNumber,
                          days: updatedDays,
                        );
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeekSection extends StatelessWidget {
  final WorkoutWeek week;
  final void Function(int dayIndex) onAddExercise;
  final void Function(int dayIndex, int exerciseIndex) onRemoveExercise;
  final void Function(int dayIndex) onToggleRestDay;

  const _WeekSection({
    required this.week,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onToggleRestDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${context.l10n.weekLabel} ${week.weekNumber}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(week.days.length, (di) {
          final day = week.days[di];
          return _DaySection(
            day: day,
            onAdd: () => onAddExercise(di),
            onRemove: (ei) => onRemoveExercise(di, ei),
            onToggleRest: () => onToggleRestDay(di),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DaySection extends StatelessWidget {
  final WorkoutDay day;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final VoidCallback onToggleRest;

  const _DaySection({
    required this.day,
    required this.onAdd,
    required this.onRemove,
    required this.onToggleRest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              day.dayName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const Spacer(),
            TextButton(
              onPressed: onToggleRest,
              child: Text(
                day.isRestDay ? context.l10n.addWorkout : context.l10n.restDayLabel,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (!day.isRestDay)
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: onAdd,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        if (day.isRestDay)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(context.l10n.restDayFull,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13)),
          )
        else
          ...List.generate(day.exercises.length, (ei) {
            final ex = day.exercises[ei];
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Type indicator strip
                  Container(
                    width: 3,
                    height: 36,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: _exerciseTypeColor(ex.type, context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                        Row(
                          children: [
                            Icon(_exerciseTypeIcon(ex.type),
                                size: 11,
                                color: _exerciseTypeColor(ex.type, context)),
                            const SizedBox(width: 3),
                            Text(
                              _exerciseSummary(ex),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => onRemove(ei),
                    visualDensity: VisualDensity.compact,
                    color: Colors.red,
                  ),
                ],
              ),
            );
          }),
        if (!day.isRestDay && day.exercises.isEmpty)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.addExercise,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Exercise type helpers (shared within this file) ─────────────────────────

Color _exerciseTypeColor(String type, BuildContext context) {
  switch (type) {
    case ExerciseType.cardio:
      return const Color(0xFFE65100);
    case ExerciseType.stretching:
      return const Color(0xFF2E7D32);
    default:
      return Theme.of(context).colorScheme.primary;
  }
}

IconData _exerciseTypeIcon(String type) {
  switch (type) {
    case ExerciseType.cardio:
      return Icons.directions_run;
    case ExerciseType.stretching:
      return Icons.self_improvement;
    default:
      return Icons.fitness_center;
  }
}

String _exerciseSummary(ExerciseModel ex) {
  switch (ex.type) {
    case ExerciseType.cardio:
      final min = ex.durationSeconds != null
          ? '${(ex.durationSeconds! / 60).round()} dk'
          : '—';
      final km = ex.distanceMeters != null
          ? ' · ${(ex.distanceMeters! / 1000).toStringAsFixed(1)} km'
          : '';
      return '$min$km';
    case ExerciseType.stretching:
      final sets = '${ex.sets} set';
      final hold = ex.durationSeconds != null
          ? ' · ${ex.durationSeconds} sn tutma'
          : '';
      return '$sets$hold';
    default: // strength
      var s = '${ex.sets} set × ${ex.reps} tekrar';
      if (ex.weight != null) s += ' · ${ex.weight} kg';
      if (ex.restSeconds != null) s += ' · ${ex.restSeconds} sn';
      return s;
  }
}

// ─── Add Exercise Bottom Sheet ────────────────────────────────────────────────

class _AddExerciseSheet extends StatefulWidget {
  final void Function(ExerciseModel) onAdd;

  const _AddExerciseSheet({required this.onAdd});

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  String _type = ExerciseType.strength;

  // Common
  final _nameCtrl  = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Strength
  final _setsCtrl   = TextEditingController(text: '3');
  final _repsCtrl   = TextEditingController(text: '10');
  final _weightCtrl = TextEditingController();
  final _restCtrl   = TextEditingController(text: '60');

  // Cardio
  final _durationCtrl = TextEditingController(text: '20'); // minutes
  final _distanceCtrl = TextEditingController();           // km

  // Stretching
  final _holdSetsCtrl = TextEditingController(text: '3');
  final _holdCtrl     = TextEditingController(text: '30'); // seconds

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    _restCtrl.dispose();
    _durationCtrl.dispose();
    _distanceCtrl.dispose();
    _holdSetsCtrl.dispose();
    _holdCtrl.dispose();
    super.dispose();
  }

  ExerciseModel _buildExercise() {
    final name = _nameCtrl.text.trim();
    final notes =
        _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null;

    switch (_type) {
      case ExerciseType.cardio:
        final mins = int.tryParse(_durationCtrl.text) ?? 20;
        final km   = double.tryParse(_distanceCtrl.text);
        return ExerciseModel(
          type:            ExerciseType.cardio,
          name:            name,
          durationSeconds: mins * 60,
          distanceMeters:  km != null ? km * 1000 : null,
          notes:           notes,
        );

      case ExerciseType.stretching:
        return ExerciseModel(
          type:            ExerciseType.stretching,
          name:            name,
          sets:            int.tryParse(_holdSetsCtrl.text) ?? 3,
          durationSeconds: int.tryParse(_holdCtrl.text),
          notes:           notes,
        );

      default: // strength
        return ExerciseModel(
          type:        ExerciseType.strength,
          name:        name,
          sets:        int.tryParse(_setsCtrl.text) ?? 3,
          reps:        int.tryParse(_repsCtrl.text) ?? 10,
          weight:      double.tryParse(_weightCtrl.text),
          restSeconds: int.tryParse(_restCtrl.text),
          notes:       notes,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n  = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                Text(
                  l10n.addExercise,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Type selector ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 12),
                  visualDensity: VisualDensity.compact,
                ),
                segments: [
                  ButtonSegment(
                    value: ExerciseType.strength,
                    icon: const Icon(Icons.fitness_center, size: 15),
                    label: Text(l10n.exerciseTypeStrength),
                  ),
                  ButtonSegment(
                    value: ExerciseType.cardio,
                    icon: const Icon(Icons.directions_run, size: 15),
                    label: Text(l10n.exerciseTypeCardio),
                  ),
                  ButtonSegment(
                    value: ExerciseType.stretching,
                    icon: const Icon(Icons.self_improvement, size: 15),
                    label: Text(l10n.exerciseTypeStretching),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) =>
                    setState(() => _type = s.first),
              ),
            ),
            const SizedBox(height: 16),

            // ── Exercise name (common) ────────────────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.exerciseName,
                prefixIcon: Icon(
                  _exerciseTypeIcon(_type),
                  color: _exerciseTypeColor(_type, context),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Type-specific fields ─────────────────────────────────────────
            if (_type == ExerciseType.strength) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _setsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.sets),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _repsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.reps),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _weightCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.weightKg,
                        suffixText: 'kg',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _restCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.restSeconds,
                  suffixText: 'sn',
                  prefixIcon: const Icon(Icons.timer_outlined, size: 20),
                ),
              ),
            ],

            if (_type == ExerciseType.cardio) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.durationMinLabel,
                        suffixText: 'dk',
                        prefixIcon:
                            const Icon(Icons.timer_outlined, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _distanceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.distanceKmLabel,
                        suffixText: 'km',
                        prefixIcon:
                            const Icon(Icons.route_outlined, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (_type == ExerciseType.stretching) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _holdSetsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.sets),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _holdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.holdSecLabel,
                        suffixText: 'sn',
                        prefixIcon:
                            const Icon(Icons.hourglass_bottom_outlined, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),

            // ── Notes (common) ───────────────────────────────────────────────
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: l10n.noteLabel,
                prefixIcon: const Icon(Icons.notes_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // ── Add button ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (_nameCtrl.text.trim().isEmpty) return;
                  widget.onAdd(_buildExercise());
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.addExercise),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
