import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/app_error.dart';
import '../../../pt_programs/providers/pt_programs_provider.dart';

class ProgramListScreen extends ConsumerWidget {
  const ProgramListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: AppError(message: e.toString())),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _ProgramListContent(ptId: user.uid);
      },
    );
  }
}

class _ProgramListContent extends ConsumerWidget {
  final String ptId;

  const _ProgramListContent({required this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(ptProgramsProvider(ptId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.createProgram),
          ),
        ],
      ),
      body: programsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppError(
          message: e.toString(),
          onRetry: () => ref.invalidate(ptProgramsProvider(ptId)),
        ),
        data: (programs) {
          if (programs.isEmpty) {
            return AppEmpty(
              message: 'Henüz program oluşturmadınız',
              subMessage: 'Üyeleriniz için antrenman programı oluşturun',
              icon: Icons.fitness_center_outlined,
              action: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.createProgram),
                icon: const Icon(Icons.add),
                label: const Text('Program Oluştur'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ptProgramsProvider(ptId)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: programs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final p = programs[i];
                return Card(
                  child: ListTile(
                    onTap: () => context.push('/pt/programs/${p.id}'),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      p.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${p.memberName} • ${p.weeks.length} hafta',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          p.createdAt.formattedDate,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: p.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.isActive ? 'Aktif' : 'Pasif',
                            style: TextStyle(
                              fontSize: 11,
                              color: p.isActive ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createProgram),
        child: const Icon(Icons.add),
      ),
    );
  }
}
