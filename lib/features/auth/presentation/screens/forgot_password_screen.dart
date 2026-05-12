import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).sendPasswordReset(
          _emailCtrl.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (!state.hasError) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.forgotPasswordTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent ? _buildSuccessView(context) : _buildFormView(context, authState),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context, AsyncValue authState) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            l10n.resetPassword,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.resetPasswordSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            controller: _emailCtrl,
            label: l10n.email,
            hint: l10n.emailHint,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.email,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: authState.isLoading ? null : _sendReset,
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.sendResetLink),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.emailSent,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.emailSentMessage(_emailCtrl.text),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => context.pop(),
          child: Text(l10n.backToLogin),
        ),
      ],
    );
  }
}
