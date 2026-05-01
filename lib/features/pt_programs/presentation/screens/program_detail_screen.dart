import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

import '../../../../shared/models/program_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error.dart';
import '../../../pt_programs/providers/pt_programs_provider.dart';

class ProgramDetailScreen extends ConsumerWidget {
  final String programId;

  const ProgramDetailScreen({super.key, required this.programId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auto-navigate away when document is deleted (stream fires null)
    ref.listen<AsyncValue<ProgramModel?>>(programDetailProvider(programId),
        (prev, next) {
      final hadValue = prev?.hasValue == true && prev?.value != null;
      final nowNull = next.hasValue && next.value == null;
      if (hadValue && nowNull && context.mounted) {
        context.go(AppRoutes.ptPrograms);
      }
    });

    final programAsync = ref.watch(programDetailProvider(programId));

    return programAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: AppError(message: e.toString())),
      data: (program) {
        if (program == null) {
          return const Scaffold(body: AppLoading());
        }

        return DefaultTabController(
          length: program.weeks.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(program.title),
              actions: [
                PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(children: [
                        Icon(program.isActive
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(program.isActive ? 'Pasife Al' : 'Aktive Et'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sil', style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                  onSelected: (value) async {
                    final repo = ref.read(programRepositoryProvider);
                    if (value == 'edit') {
                      context.push('/pt/programs/${program.id}/edit',
                          extra: program);
                    } else if (value == 'toggle') {
                      await repo.updateProgram(
                          program.id, {'isActive': !program.isActive});
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (dialogCtx) => AlertDialog(
                          title: const Text('Programı Sil'),
                          content: const Text(
                              'Bu programı kalıcı olarak silmek istiyor musunuz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx, false),
                              child: const Text('İptal'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dialogCtx, true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Sil'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        debugPrint('[DELETE] Starting delete for program: ${program.id}');
                        try {
                          await repo.deleteProgram(program.id);
                          debugPrint('[DELETE] Success');
                          if (context.mounted) context.go(AppRoutes.ptPrograms);
                        } catch (e, st) {
                          debugPrint('[DELETE] Error: $e\n$st');
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Silme Hatası'),
                                content: Text(e.toString()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Tamam'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: List.generate(
                  program.weeks.length,
                  (i) => Tab(text: 'Hafta ${i + 1}'),
                ),
              ),
            ),
            body: TabBarView(
              children: program.weeks
                  .map((week) => _WeekTab(week: week))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _WeekTab extends StatelessWidget {
  final week;

  const _WeekTab({required this.week});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: week.days.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final day = week.days[i];
        return _DayCard(day: day);
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  day.isRestDay
                      ? Icons.hotel_outlined
                      : Icons.fitness_center,
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
                if (day.isRestDay) ...[
                  const Spacer(),
                  Text(
                    'Dinlenme',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
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
          if (!day.isRestDay && day.exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: List.generate(day.exercises.length, (i) {
                  final ex = day.exercises[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
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
                                fontSize: 12,
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
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${ex.sets} set × ${ex.reps} tekrar'
                                '${ex.weight != null ? ' • ${ex.weight} kg' : ''}'
                                '${ex.restSeconds != null ? ' • ${ex.restSeconds}sn dinlenme' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
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
          if (!day.isRestDay && day.exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Henüz egzersiz eklenmedi',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
