import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

class PtOtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const PtOtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<PtOtpScreen> createState() => _PtOtpScreenState();
}

class _PtOtpScreenState extends ConsumerState<PtOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showError('Lütfen 6 haneli kodu girin.');
      return;
    }

    setState(() => _isLoading = true);
    final success = await ref
        .read(authNotifierProvider.notifier)
        .verifyOtpAndGetUser(otp);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final user = ref.read(authNotifierProvider).valueOrNull;
      if (user == null) {
        // Yeni PT: kayıt ekranına yönlendir
        context.go(AppRoutes.ptRegister);
      } else {
        context.go(AppRoutes.ptHome);
      }
    } else {
      _showError('Geçersiz kod. Lütfen tekrar deneyin.');
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
      appBar: AppBar(title: const Text('Kod Doğrulama')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              'Doğrulama Kodu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.phoneNumber} numarasına gönderilen 6 haneli kodu girin.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
              decoration: const InputDecoration(
                labelText: 'Doğrulama Kodu',
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Doğrula'),
            ),
          ],
        ),
      ),
    );
  }
}
