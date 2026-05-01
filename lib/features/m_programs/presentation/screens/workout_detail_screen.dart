import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/pt_programs/providers/pt_programs_provider.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error.dart';

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
          return const Scaffold(
              body: Center(child: Text('Program bulunamadı')));
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
                  (i) => Tab(text: 'Hafta ${i + 1}'),
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
                    '${day.exercises.length} egzersiz',
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Bugün dinlenme günü 🛌 İyi dinlenmeler!'),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: List.generate(day.exercises.length, (i) {
                  final ex = day.exercises[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
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
                              Text(
                                '${ex.sets} set × ${ex.reps} tekrar'
                                '${ex.weight != null ? ' • ${ex.weight} kg' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (ex.notes != null)
                                Text(
                                  ex.notes!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (ex.restSeconds != null)
                          Column(
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
