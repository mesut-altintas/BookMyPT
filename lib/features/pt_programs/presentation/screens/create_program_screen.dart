import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/models/program_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../pt_members/providers/pt_members_provider.dart';
import '../../../pt_programs/providers/pt_programs_provider.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  final ProgramModel? initialProgram;

  const CreateProgramScreen({super.key, this.initialProgram});

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
        const SnackBar(content: Text('Lütfen bir üye seçin')),
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
            const SnackBar(content: Text('Program güncellendi')),
          );
          context.pop();
        }
      } else {
        await repo.createProgram(program);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Program oluşturuldu')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
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
    if (_isLoading) return const Scaffold(body: AppLoading(message: 'Kaydediliyor...'));

    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        final membersAsync = ref.watch(ptMembersProvider(user.uid));

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Programı Düzenle' : 'Program Oluştur'),
            actions: [
              TextButton(onPressed: _save, child: const Text('Kaydet')),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  validator: (v) => Validators.required(v, 'Program adı'),
                  decoration: const InputDecoration(
                    labelText: 'Program Adı',
                    hintText: 'Başlangıç Programı',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (İsteğe bağlı)',
                    hintText: 'Program hakkında kısa bilgi',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                membersAsync.when(
                  loading: () => const AppLoading(size: 24),
                  error: (_, __) => const Text('Üyeler yüklenemedi'),
                  data: (members) => DropdownButtonFormField<String>(
                    value: _selectedMemberId,
                    hint: const Text('Üye Seç'),
                    items: members
                        .map((m) => DropdownMenuItem(
                              value: m.memberId,
                              child: Text(m.name),
                              onTap: () => _selectedMemberName = m.name,
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMemberId = v),
                    decoration: const InputDecoration(
                      labelText: 'Üye',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Hafta Sayısı:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
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
            'Hafta ${week.weekNumber}',
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
                day.isRestDay ? 'Antrenman Ekle' : 'Dinlenme Günü',
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
            child: const Text('Dinlenme Günü 🛌',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13)),
          )
        else
          ...List.generate(day.exercises.length, (ei) {
            final ex = day.exercises[ei];
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                        Text(
                          '${ex.sets} set × ${ex.reps} tekrar${ex.weight != null ? ' • ${ex.weight} kg' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
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
                    'Egzersiz Ekle',
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

class _AddExerciseSheet extends StatefulWidget {
  final void Function(ExerciseModel) onAdd;

  const _AddExerciseSheet({required this.onAdd});

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _nameCtrl = TextEditingController();
  final _setsCtrl = TextEditingController(text: '3');
  final _repsCtrl = TextEditingController(text: '10');
  final _weightCtrl = TextEditingController();
  final _restCtrl = TextEditingController(text: '60');
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    _restCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Egzersiz Ekle',
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
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Egzersiz Adı'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Set'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _repsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tekrar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ağırlık (kg)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _restCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Dinlenme (sn)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(labelText: 'Not'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_nameCtrl.text.isEmpty) return;
                widget.onAdd(ExerciseModel(
                  name: _nameCtrl.text.trim(),
                  sets: int.tryParse(_setsCtrl.text) ?? 3,
                  reps: int.tryParse(_repsCtrl.text) ?? 10,
                  weight: double.tryParse(_weightCtrl.text),
                  restSeconds: int.tryParse(_restCtrl.text),
                  notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
                ));
                Navigator.pop(context);
              },
              child: const Text('Egzersiz Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
