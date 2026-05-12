import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_calendar/providers/invitation_provider.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../pt_members/providers/pt_members_provider.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _goalCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final memberRepo = ref.read(memberRepositoryProvider);
    final invRepo = ref.read(invitationRepositoryProvider);

    try {
      // Look up member by email to get their uid (if already registered)
      final memberUser =
          await memberRepo.getUserByEmail(_emailCtrl.text.trim());

      if (memberUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.memberNotFoundByEmail),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      await invRepo.createInvitation(
        ptId: user.uid,
        ptName: user.name,
        memberEmail: _emailCtrl.text.trim(),
        memberId: memberUser.uid,
        goal: _goalCtrl.text.trim().isNotEmpty ? _goalCtrl.text.trim() : null,
        notes:
            _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.invitationSent(memberUser.name)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addMemberTitle)),
      body: _isLoading
          ? AppLoading(message: context.l10n.sendingInvitation)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.memberInfo,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.memberEmailInstructions,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      decoration: InputDecoration(
                        labelText: context.l10n.memberEmail,
                        hintText: context.l10n.emailHint,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _goalCtrl,
                      decoration: InputDecoration(
                        labelText: context.l10n.goalOptional,
                        hintText: context.l10n.goalHintAlt,
                        prefixIcon: const Icon(Icons.flag_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: context.l10n.notesOptional,
                        hintText: context.l10n.notesHint,
                        prefixIcon: const Icon(Icons.notes_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _sendInvitation,
                      child: Text(context.l10n.sendInvitation),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
