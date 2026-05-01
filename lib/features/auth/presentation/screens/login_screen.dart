import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../../../features/pt_members/providers/pt_members_provider.dart';
import '../../../../features/pt_calendar/providers/pt_calendar_provider.dart';
import '../../../../features/m_chat/providers/chat_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      _showError(_parseError(state.error.toString()));
      return;
    }
    await _navigateBasedOnRole();
  }

  Future<void> _loginWithGoogle() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signInWithGoogle();
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      _showError('Google ile giriş başarısız');
      return;
    }
    await _navigateBasedOnRole();
  }

  Future<void> _navigateBasedOnRole() async {
    // Wait for currentUserProvider to finish loading (max 5s)
    for (var i = 0; i < 50; i++) {
      if (!ref.read(currentUserProvider).isLoading) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;

    // Invalidate all family providers so stale streams from the previous user
    // session don't carry permission-denied errors into the new session.
    ref.invalidate(ptMembersProvider);
    ref.invalidate(ptSessionsProvider);
    ref.invalidate(upcomingSessionsProvider);
    ref.invalidate(memberSessionsProvider);
    ref.invalidate(memberUpcomingSessionsProvider);
    ref.invalidate(chatRoomsProvider);

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      // Authenticated but no Firestore profile yet → go to role selection
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) context.go(AppRoutes.roleSelection, extra: uid);
      return;
    }
    if (user.role == AppConstants.roleTrainer) {
      context.go(AppRoutes.ptDashboard);
    } else {
      context.go(AppRoutes.memberDashboard);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'Bu e-posta kayıtlı değil';
    if (error.contains('wrong-password')) return 'Şifre hatalı';
    if (error.contains('invalid-credential')) return 'E-posta veya şifre hatalı';
    if (error.contains('too-many-requests')) return 'Çok fazla deneme. Lütfen bekleyin';
    if (error.contains('invalid-email')) return 'Geçersiz e-posta adresi';
    if (error.contains('network-request-failed')) return 'İnternet bağlantısı hatası';
    if (error.contains('user-disabled')) return 'Bu hesap devre dışı bırakıldı';
    return 'Giriş başarısız. Lütfen tekrar deneyin';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Hoş Geldiniz',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hesabınıza giriş yapın',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
                AuthTextField(
                  controller: _emailCtrl,
                  label: 'E-posta',
                  hint: 'ornek@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passCtrl,
                  label: 'Şifre',
                  hint: '••••••',
                  obscureText: _obscurePass,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  validator: Validators.password,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: const Text('Şifremi Unuttum'),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Giriş Yap'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'veya',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                GoogleSignInButton(onPressed: isLoading ? null : _loginWithGoogle),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabınız yok mu? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: const Text('Kayıt Ol'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
