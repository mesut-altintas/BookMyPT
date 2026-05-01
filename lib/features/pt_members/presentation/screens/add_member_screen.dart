import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/models/member_model.dart';
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

  Future<void> _addMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final repo = ref.read(memberRepositoryProvider);

    try {
      final memberUser = await repo.getUserByEmail(_emailCtrl.text.trim());

      if (memberUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Bu e-posta ile kayıtlı üye bulunamadı. Önce üye kayıt olmalıdır.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final member = MemberProfile(
        memberId: memberUser.uid,
        name: memberUser.name,
        email: memberUser.email,
        photoUrl: memberUser.photoUrl,
        goal: _goalCtrl.text.trim().isNotEmpty ? _goalCtrl.text.trim() : null,
        notes:
            _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        joinedAt: DateTime.now(),
      );

      await repo.addMember(ptId: user.uid, member: member);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${memberUser.name} başarıyla eklendi'),
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
      appBar: AppBar(title: const Text('Üye Ekle')),
      body: _isLoading
          ? const AppLoading(message: 'Ekleniyor...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Üye Bilgileri',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Üyenin e-posta adresiyle arama yapın. Üye önce uygulamaya kayıt olmuş olmalıdır.',
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
                      decoration: const InputDecoration(
                        labelText: 'Üye E-postası',
                        hintText: 'uye@email.com',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _goalCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Hedef (İsteğe bağlı)',
                        hintText: 'Kilo verme, kas kazanma...',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notlar (İsteğe bağlı)',
                        hintText: 'Özel durumlar, sağlık notları...',
                        prefixIcon: Icon(Icons.notes_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _addMember,
                      child: const Text('Üye Ekle'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
