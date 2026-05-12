import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../providers/invitation_provider.dart';
import '../../../../features/pt_members/providers/pt_members_provider.dart';
import '../../../../shared/models/invitation_model.dart';

class InvitationListScreen extends ConsumerWidget {
  const InvitationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationsAsync = ref.watch(memberInvitationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.invitationListTitle)),
      body: invitationsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (invitations) {
          if (invitations.isEmpty) {
            return AppEmpty(
              message: context.l10n.noPendingInvitations,
              subMessage: context.l10n.noInvitationsYetSub,
              icon: Icons.mail_outline,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: invitations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _InvitationCard(invitation: invitations[i]),
          );
        },
      ),
    );
  }
}

class _InvitationCard extends ConsumerStatefulWidget {
  final InvitationModel invitation;

  const _InvitationCard({required this.invitation});

  @override
  ConsumerState<_InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends ConsumerState<_InvitationCard> {
  bool _loading = false;

  Future<void> _respond(bool accept) async {
    setState(() => _loading = true);
    try {
      final invRepo = ref.read(invitationRepositoryProvider);
      if (accept) {
        final memberRepo = ref.read(memberRepositoryProvider);
        await invRepo.acceptInvitation(
          invitation: widget.invitation,
          memberRepo: memberRepo,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.ptConnected(widget.invitation.ptName)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await invRepo.rejectInvitation(widget.invitation.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.invitationRejected),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inv = widget.invitation;
    final dateStr =
        DateFormat('d MMM yyyy', 'tr').format(inv.createdAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.sports_gymnastics,
                      color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.ptName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(context.l10n.invitationDate(dateStr),
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            if (inv.goal != null && inv.goal!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _InfoRow(
                  icon: Icons.flag_outlined, label: context.l10n.goal, value: inv.goal!),
            ],
            if (inv.notes != null && inv.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _InfoRow(
                  icon: Icons.notes_outlined, label: context.l10n.noteLabel, value: inv.notes!),
            ],
            const SizedBox(height: 16),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _respond(false),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error),
                          child: Text(context.l10n.reject),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _respond(true),
                          child: Text(context.l10n.accept),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text('$label: ',
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
