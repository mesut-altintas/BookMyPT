import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../data/models/member_model.dart';
import '../providers/members_provider.dart';
import 'package_edit_dialog.dart';

class MemberCard extends ConsumerWidget {
  final MemberModel member;

  const MemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(membersNotifierProvider.notifier);
    final isActive = member.status == MemberStatus.active;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst satır: isim + aktif badge
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      isActive ? AppColors.primary : Colors.grey.shade400,
                  child: Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        member.phone,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _StatusChip(isActive: isActive),
              ],
            ),
            const SizedBox(height: 12),
            // Paket bilgisi
            _PackageBar(member: member),
            const SizedBox(height: 12),
            // Erişim kodu
            _AccessCodeRow(code: member.accessCode),
            const Divider(height: 20),
            // Toggle'lar + butonlar
            Row(
              children: [
                Expanded(
                  child: _ToggleItem(
                    label: isActive ? 'Aktif' : 'Pasif',
                    icon: isActive ? Icons.check_circle : Icons.cancel,
                    color: isActive ? AppColors.success : Colors.grey,
                    value: isActive,
                    onChanged: (_) => notifier.toggleStatus(member),
                  ),
                ),
                Expanded(
                  child: _ToggleItem(
                    label: 'Takvim',
                    icon: member.calendarAccess
                        ? Icons.calendar_month
                        : Icons.calendar_month_outlined,
                    color: member.calendarAccess ? AppColors.primary : Colors.grey,
                    value: member.calendarAccess,
                    onChanged: (_) => notifier.toggleCalendarAccess(member),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.inventory_2_outlined),
                  tooltip: 'Paket Düzenle',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => PackageEditDialog(
                      member: member,
                      onSave: (pkg) => notifier.updatePackage(member, pkg),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Üyeyi Sil',
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Üyeyi Sil'),
        content: Text('${member.name} silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ref.read(membersNotifierProvider.notifier).deleteMember(member.id);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.success.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.success : Colors.grey,
          ),
        ),
        child: Text(
          isActive ? 'Aktif' : 'Pasif',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.success : Colors.grey,
          ),
        ),
      );
}

class _PackageBar extends StatelessWidget {
  final MemberModel member;
  const _PackageBar({required this.member});

  @override
  Widget build(BuildContext context) {
    final pkg = member.package;
    if (pkg.total == 0) {
      return Text(
        'Paket tanımlanmamış',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      );
    }
    final progress = pkg.total > 0 ? pkg.used / pkg.total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kalan: ${pkg.remaining} / ${pkg.total} ders',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              '${pkg.used} kullanıldı',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              pkg.remaining <= 2 ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccessCodeRow extends StatelessWidget {
  final String code;
  const _AccessCodeRow({required this.code});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.vpn_key, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            'Erişim Kodu: ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            code,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erişim kodu kopyalandı.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(Icons.copy, size: 16, color: Colors.grey),
          ),
        ],
      );
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: color,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 2),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
}
