import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/session_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../pt_calendar/providers/pt_calendar_provider.dart';
import '../../../pt_members/providers/pt_members_provider.dart';

class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionDetailProvider(sessionId));

    return sessionAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: AppError(message: e.toString())),
      data: (session) {
        if (session == null) {
          return const Scaffold(
              body: Center(child: Text('Seans bulunamadı')));
        }
        return _SessionDetailContent(session: session);
      },
    );
  }
}

class _SessionDetailContent extends ConsumerWidget {
  final SessionModel session;

  const _SessionDetailContent({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(sessionRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seans Detayı'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Seansı Sil'),
                    content: const Text('Bu seansı silmek istiyor musunuz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('İptal'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Sil'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  final messenger = ScaffoldMessenger.of(context);
                  context.go(AppRoutes.ptCalendar);
                  try {
                    await repo.deleteSession(session.id);
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(
                      content: Text('Silme hatası: $e'),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.memberName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer
                            .withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        session.dateTime.formattedDateTime,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer
                            .withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${session.durationMinutes} dakika',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status
            Row(
              children: [
                const Text(
                  'Durum',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const Spacer(),
                StatusBadge.session(session.status),
              ],
            ),
            const SizedBox(height: 16),

            // Status Actions
            if (session.status == SessionStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await repo.updateStatus(
                            session.id, SessionStatus.cancelled);
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('İptal Et'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await repo.updateStatus(
                            session.id, SessionStatus.confirmed);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Onayla'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            if (session.status == SessionStatus.confirmed) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  await repo.updateStatus(
                      session.id, SessionStatus.completed);
                  await ref.read(memberRepositoryProvider).updateRemainingSessions(
                        ptId: session.ptId,
                        memberId: session.memberId,
                        delta: -1,
                      );
                },
                icon: const Icon(Icons.done_all),
                label: const Text('Tamamlandı Olarak İşaretle'),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const Text(
                'Notlar',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(session.notes!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
