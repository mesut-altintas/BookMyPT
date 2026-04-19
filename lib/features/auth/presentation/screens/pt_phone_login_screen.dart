import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

class PtPhoneLoginScreen extends ConsumerStatefulWidget {
  const PtPhoneLoginScreen({super.key});

  @override
  ConsumerState<PtPhoneLoginScreen> createState() => _PtPhoneLoginScreenState();
}

class _PtPhoneLoginScreenState extends ConsumerState<PtPhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showError('Lütfen telefon numaranızı girin.');
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(authNotifierProvider.notifier).sendOtp(
      phone.startsWith('+') ? phone : '+90${phone.replaceAll(' ', '')}',
      onCodeSent: (verificationId) {
        setState(() => _isLoading = false);
        context.go(AppRoutes.ptOtp, extra: phone);
      },
      onError: (error) {
        setState(() => _isLoading = false);
        _showError(error);
      },
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PT Girişi')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              'Telefon numaranızı girin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Size doğrulama kodu göndereceğiz.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon Numarası',
                hintText: '05XX XXX XX XX',
                prefixIcon: Icon(Icons.phone),
                prefixText: '+90 ',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Kod Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
