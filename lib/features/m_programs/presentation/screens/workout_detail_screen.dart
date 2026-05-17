import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../features/pt_programs/providers/pt_programs_provider.dart';
import '../../../../shared/models/program_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error.dart';

// ─── Exercise type helpers ────────────────────────────────────────────────────

Color _typeColor(String type, BuildContext context) {
  switch (type) {
    case ExerciseType.cardio:     return const Color(0xFFE65100);
    case ExerciseType.stretching: return const Color(0xFF2E7D32);
    default:                      return Theme.of(context).colorScheme.primary;
  }
}

IconData _typeIcon(String type) {
  switch (type) {
    case ExerciseType.cardio:     return Icons.directions_run;
    case ExerciseType.stretching: return Icons.self_improvement;
    default:                      return Icons.fitness_center;
  }
}

String _exSummary(ExerciseModel ex) {
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
    default:
      var s = '${ex.sets} set × ${ex.reps} tekrar';
      if (ex.weight != null)      s += ' · ${ex.weight} kg';
      if (ex.restSeconds != null) s += ' · ${ex.restSeconds} sn';
      return s;
  }
}

class WorkoutDetailScreen extends ConsumerWidget {
  final String programId;

  const WorkoutDetailScreen({super.key, required this.programId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(programDetailProvider(programId));

    return programAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: AppError(message: e.toString())),
      data: (program) {
        if (program == null) {
          return Scaffold(
              body: Center(child: Text(context.l10n.programNotFound)));
        }

        return DefaultTabController(
          length: program.weeks.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(program.title),
              bottom: TabBar(
                isScrollable: true,
                tabs: List.generate(
                  program.weeks.length,
                  (i) => Tab(text: '${context.l10n.weekLabel} ${i + 1}'),
                ),
              ),
            ),
            body: TabBarView(
              children: program.weeks.map((week) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: week.days.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, di) {
                    final day = week.days[di];
                    return _DayCard(day: day);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _DayCard extends StatelessWidget {
  final day;

  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: day.isRestDay
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primaryContainer,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  day.isRestDay ? Icons.hotel_outlined : Icons.fitness_center,
                  size: 18,
                  color: day.isRestDay
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  day.dayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: day.isRestDay
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                if (!day.isRestDay) ...[
                  const Spacer(),
                  Text(
                    context.l10n.exercisesCount(day.exercises.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (day.isRestDay)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.restDayMessage),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: List.generate(day.exercises.length, (i) {
                  final ex = day.exercises[i];
                  final tColor = _typeColor(ex.type, context);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge: number colored by type
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: tColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(_typeIcon(ex.type),
                                      size: 12, color: tColor),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      _exSummary(ex),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (ex.notes != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  ex.notes!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Rest timer badge — strength only
                        if (ex.isStrength && ex.restSeconds != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              children: [
                                Icon(Icons.timer_outlined,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant),
                                Text(
                                  '${ex.restSeconds}s',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
