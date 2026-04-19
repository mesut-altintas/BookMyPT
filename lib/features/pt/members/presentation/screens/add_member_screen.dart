import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/member_model.dart';
import '../providers/members_provider.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isSaving = false;
  MemberModel? _createdMember;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickContact() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rehber izni verilmedi.')),
      );
      return;
    }

    try {
      final contact = await FlutterContacts.openExternalPick();
      if (contact == null) return;

      final full = await FlutterContacts.getContact(contact.id);
      if (full == null) return;

      setState(() {
        _nameCtrl.text = full.displayName;
        if (full.phones.isNotEmpty) {
          _phoneCtrl.text = full.phones.first.number.replaceAll(' ', '');
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rehber açılamadı.')),
      );
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad ve telefon zorunludur.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final member = await ref
        .read(membersNotifierProvider.notifier)
        .addMember(name: name, phone: phone);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _createdMember = member;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Üye Ekle')),
      body: _createdMember != null
          ? _SuccessView(member: _createdMember!)
          : _FormView(
              nameCtrl: _nameCtrl,
              phoneCtrl: _phoneCtrl,
              isSaving: _isSaving,
              onPickContact: _pickContact,
              onSave: _save,
            ),
    );
  }
}

class _FormView extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final bool isSaving;
  final VoidCallback onPickContact;
  final VoidCallback onSave;

  const _FormView({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.isSaving,
    required this.onPickContact,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Ad Soyad',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefon Numarası',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onPickContact,
            icon: const Icon(Icons.contacts),
            label: const Text('Rehberden Seç'),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Üye Ekle'),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final MemberModel member;

  const _SuccessView({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          Text(
            '${member.name} eklendi!',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          const Text(
            'Üyenize iletmeniz gereken bilgiler:',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                const Text('Telefon', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  member.phone,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Erişim Kodu', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  member.accessCode,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: 'BookMyPT Giriş Bilgileri\nTelefon: ${member.phone}\nErişim Kodu: ${member.accessCode}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bilgiler kopyalandı.')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Bilgileri Kopyala'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Geri Dön'),
          ),
        ],
      ),
    );
  }
}
