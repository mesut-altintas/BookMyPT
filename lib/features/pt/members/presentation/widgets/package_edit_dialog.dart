import 'package:flutter/material.dart';
import '../../data/models/member_model.dart';

class PackageEditDialog extends StatefulWidget {
  final MemberModel member;
  final void Function(MemberPackage) onSave;

  const PackageEditDialog({
    super.key,
    required this.member,
    required this.onSave,
  });

  @override
  State<PackageEditDialog> createState() => _PackageEditDialogState();
}

class _PackageEditDialogState extends State<PackageEditDialog> {
  late final TextEditingController _totalCtrl;
  late final TextEditingController _usedCtrl;

  @override
  void initState() {
    super.initState();
    _totalCtrl = TextEditingController(
        text: widget.member.package.total.toString());
    _usedCtrl = TextEditingController(
        text: widget.member.package.used.toString());
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    _usedCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final total = int.tryParse(_totalCtrl.text) ?? 0;
    final used = int.tryParse(_usedCtrl.text) ?? 0;
    if (used > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanılan ders toplam dersten fazla olamaz.')),
      );
      return;
    }
    widget.onSave(MemberPackage(total: total, used: used));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.member.name} — Paket'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _totalCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Toplam Ders',
              suffixText: 'ders',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _usedCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Kullanılan Ders',
              suffixText: 'ders',
            ),
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: Listenable.merge([_totalCtrl, _usedCtrl]),
            builder: (_, __) {
              final total = int.tryParse(_totalCtrl.text) ?? 0;
              final used = int.tryParse(_usedCtrl.text) ?? 0;
              final remaining = (total - used).clamp(0, total);
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat('Toplam', total, Colors.blue),
                    _Stat('Kullanılan', used, Colors.orange),
                    _Stat('Kalan', remaining, Colors.green),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Kaydet')),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
}
