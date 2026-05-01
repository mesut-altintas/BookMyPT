import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/pt_calendar/providers/pt_calendar_provider.dart';
import '../../../../features/pt_programs/providers/pt_programs_provider.dart';
import '../../../../shared/models/program_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/app_error.dart';

class MemberProgramsScreen extends ConsumerWidget {
  const MemberProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: AppError(message: e.toString())),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        final ptIdFromDoc = user.ptId ?? '';
        if (ptIdFromDoc.isNotEmpty) {
          return _ProgramsContent(memberId: user.uid, ptId: ptIdFromDoc);
        }
        final ptIdAsync = ref.watch(memberPtIdProvider(user.uid));
        return ptIdAsync.when(
          loading: () => _ProgramsContent(memberId: user.uid, ptId: ''),
          error: (_, __) => _ProgramsContent(memberId: user.uid, ptId: ''),
          data: (ptId) => _ProgramsContent(memberId: user.uid, ptId: ptId),
        );
      },
    );
  }
}

class _ProgramsContent extends ConsumerWidget {
  final String memberId;
  final String ptId;

  const _ProgramsContent({required this.memberId, required this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(memberProgramsProvider(memberId));
    final ptName = ptId.isNotEmpty
        ? ref.watch(ptUserProvider(ptId)).valueOrNull?.name ?? ''
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrenman Programım'),
        actions: ptName.isNotEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      'PT: $ptName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: programsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppError(message: e.toString()),
        data: (programs) {
          if (programs.isEmpty) {
            return const AppEmpty(
              message: 'Henüz program atanmadı',
              subMessage: 'PT\'niz size bir program atadığında burada görünür',
              icon: Icons.fitness_center_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: programs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final p = programs[i];
              return _ProgramCard(program: p);
            },
          );
        },
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final ProgramModel program;

  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => context.push('/member/programs/${program.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${program.weeks.length} Hafta Programı',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (program.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  program.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    program.createdAt.formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  // Week progress chips
                  ...List.generate(
                    program.weeks.length > 4 ? 4 : program.weeks.length,
                    (i) => Container(
                      width: 20,
                      height: 8,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: i == 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
