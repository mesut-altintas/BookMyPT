import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../calendar/data/models/booking_model.dart';

final _pendingCancelsProvider = StreamProvider<List<BookingModel>>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection(AppConstants.bookingsCollection)
      .where('trainerId', isEqualTo: user.id)
      .where('status', isEqualTo: 'pending_cancel')
      .orderBy('cancelRequestedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(BookingModel.fromFirestore).toList());
});

class PtCancellationsScreen extends ConsumerWidget {
  const PtCancellationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancelsAsync = ref.watch(_pendingCancelsProvider);

    return cancelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (cancels) {
        if (cancels.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('Bekleyen iptal talebi yok.',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: cancels.length,
          itemBuilder: (_, i) => _CancelCard(booking: cancels[i]),
        );
      },
    );
  }
}

class _CancelCard extends ConsumerWidget {
  final BookingModel booking;
  const _CancelCard({required this.booking});

  Future<void> _approve(BuildContext context) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    // Booking iptal et
    batch.update(
      db.collection(AppConstants.bookingsCollection).doc(booking.id),
      {'status': 'cancelled'},
    );

    // İptal onayında kullanım geri al
    batch.update(
      db.collection(AppConstants.membersCollection).doc(booking.memberId),
      {
        'package.used': FieldValue.increment(-1),
        'package.remaining': FieldValue.increment(1),
      },
    );

    await batch.commit();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İptal onaylandı. Ders paketinden düşülmedi.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _reject(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.bookingsCollection)
        .doc(booking.id)
        .update({
      'status': 'confirmed',
      'cancelRequestedAt': FieldValue.delete(),
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İptal talebi reddedildi. Ders geçerli.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                  child: const Icon(Icons.person, color: AppColors.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.memberName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        AppDateUtils.formatDateTime(booking.startTime),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: const Text(
                    'İptal Bekliyor',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (booking.cancelRequestedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                'Talep: ${AppDateUtils.formatDateTime(booking.cancelRequestedAt!)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showConfirm(
                      context,
                      title: 'İptali Reddet',
                      content:
                          '${booking.memberName} için iptal talebi reddedilecek. Ders geçerli sayılır.',
                      confirmLabel: 'Reddet',
                      color: Colors.orange,
                      onConfirm: () => _reject(context),
                    ),
                    icon: const Icon(Icons.close, color: Colors.orange),
                    label: const Text('Reddet',
                        style: TextStyle(color: Colors.orange)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showConfirm(
                      context,
                      title: 'İptali Onayla',
                      content:
                          '${booking.memberName} için iptal onaylanacak. Ders paketten düşülmeyecek.',
                      confirmLabel: 'Onayla',
                      color: Colors.green,
                      onConfirm: () => _approve(context),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Onayla'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirm(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    required Color color,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: color, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
