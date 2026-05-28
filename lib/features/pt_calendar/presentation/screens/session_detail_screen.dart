import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/extensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/session_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../pt_calendar/providers/pt_calendar_provider.dart';
import '../../../pt_members/providers/pt_members_provider.dart';

// Shared cancellation-request UI — used by both PT and Member sides.
// [role] is 'pt' or 'member' (the current user's role).
class _CancellationRequestWidget extends StatelessWidget {
  final SessionModel session;
  final String role; // 'pt' | 'member'
  final SessionRepository repo;

  const _CancellationRequestWidget({
    required this.session,
    required this.role,
    required this.repo,
  });

  String get _oppositeRole => role == 'pt' ? 'member' : 'pt';

  Future<void> _sendRequest(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.sendCancellationRequest),
        content: Text(context.l10n.cancellationRequestConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: Text(context.l10n.sendCancellationRequest),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repo.requestCancellation(session.id, role);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requested = session.cancellationRequestedBy;

    // Other side already sent a request → show Accept/Reject
    if (requested == _oppositeRole) {
      final label = role == 'pt'
          ? context.l10n.memberRequestedCancellation
          : context.l10n.ptRequestedCancellation;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      repo.rejectCancellationRequest(session.id),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error)),
                  child: Text(context.l10n.rejectCancellation),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      repo.acceptCancellationRequest(session.id),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white),
                  child: Text(context.l10n.acceptCancellation),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Current user already sent a request
    if (requested == role) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_top, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Text(context.l10n.cancellationRequestSent,
                style: const TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    // No pending request → show send button
    return OutlinedButton.icon(
      onPressed: () => _sendRequest(context),
      icon: const Icon(Icons.cancel_schedule_send_outlined),
      label: Text(context.l10n.sendCancellationRequest),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: BorderSide(color: AppColors.error),
      ),
    );
  }
}

class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionDetailProvider(sessionId));

    ref.listen(sessionDetailProvider(sessionId), (prev, next) {
      final hadValue = prev?.hasValue == true && prev?.value != null;
      final nowNull = next.hasValue && next.value == null;
      if (hadValue && nowNull && context.mounted) {
        context.go(AppRoutes.ptCalendar);
      }
    });

    return sessionAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: AppError(message: e.toString())),
      data: (session) {
        if (session == null) return const Scaffold(body: AppLoading());
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
        title: Text(context.l10n.sessionDetailTitle),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(context.l10n.delete, style: const TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) async {
              if (value == 'delete') {
                final l10n = context.l10n;
                final confirm = await showDialog<bool>(
                  context: context,
                  useRootNavigator: false,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.deleteSession),
                    content: Text(l10n.deleteSessionConfirm),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, false),
                        child: Text(l10n.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  try {
                    await repo.deleteSession(session.id);
                  } catch (e) {
                    if (context.mounted) {
                      final l10n = context.l10n;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(l10n.deleteError),
                          content: Text(e.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.close),
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
                        context.l10n.durationMinutesValue(session.durationMinutes),
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
                Text(
                  context.l10n.statusLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                      label: Text(context.l10n.cancelSession),
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
                      label: Text(context.l10n.confirm),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            if (session.status == SessionStatus.confirmed) ...[
              // Mark as Completed — disabled for future sessions
              Tooltip(
                message: session.isPast
                    ? ''
                    : context.l10n.sessionInFutureWarning,
                child: ElevatedButton.icon(
                  onPressed: session.isPast
                      ? () async {
                          final memberRepo =
                              ref.read(memberRepositoryProvider);
                          await repo.updateStatus(
                              session.id, SessionStatus.completed);
                          await memberRepo.updateRemainingSessions(
                            ptId: session.ptId,
                            memberId: session.memberId,
                            delta: -1,
                            sessionDurationMinutes: session.durationMinutes,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.done_all),
                  label: Text(context.l10n.markAsCompleted),
                ),
              ),
              const SizedBox(height: 12),

              // Cancellation request section
              _CancellationRequestWidget(
                session: session,
                role: 'pt',
                repo: repo,
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              Text(
                context.l10n.notes,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
