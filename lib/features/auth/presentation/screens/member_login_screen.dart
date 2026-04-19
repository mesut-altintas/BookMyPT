import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

class MemberLoginScreen extends ConsumerStatefulWidget {
  const MemberLoginScreen({super.key});

  @override
  ConsumerState<MemberLoginScreen> createState() => _MemberLoginScreenState();
}

class _MemberLoginScreenState extends ConsumerState<MemberLoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim().toUpperCase();

    if (phone.isEmpty || code.isEmpty) {
      _showError('Lütfen tüm alanları doldurun.');
      return;
    }
    if (code.length != 6) {
      _showError('Erişim kodu 6 haneli olmalıdır.');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authNotifierProvider.notifier).loginAsMember(
          phone: phone,
          accessCode: code,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go(AppRoutes.memberHome);
    } else {
      final state = ref.read(authNotifierProvider);
      state.when(
        data: (_) => _showError('Giriş başarısız.'),
        loading: () {},
        error: (e, _) => _showError(e.toString()),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üye Girişi')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              'Üye Girişi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Personal Trainer\'ınızdan aldığınız bilgileri girin.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon Numarası',
                prefixIcon: Icon(Icons.phone),
                hintText: '05XX XXX XX XX',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Erişim Kodu',
                prefixIcon: Icon(Icons.vpn_key),
                hintText: 'XXXXXX',
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
