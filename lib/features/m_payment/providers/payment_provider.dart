import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/payment_model.dart';

final memberPaymentsProvider =
    StreamProvider.family<List<PaymentModel>, String>((ref, memberId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <PaymentModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.paymentsCollection)
      .where('memberId', isEqualTo: memberId)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => PaymentModel.fromFirestore(d)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }).handleError((e, st) {});
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(FirebaseFirestore.instance);
});

class PaymentRepository {
  const PaymentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<String> createPayment(PaymentModel payment) async {
    final doc =
        _firestore.collection(AppConstants.paymentsCollection).doc();
    final newPayment = PaymentModel(
      id: doc.id,
      memberId: payment.memberId,
      ptId: payment.ptId,
      amount: payment.amount,
      currency: payment.currency,
      status: payment.status,
      packageName: payment.packageName,
      sessionCount: payment.sessionCount,
      createdAt: payment.createdAt,
      transactionId: payment.transactionId,
    );
    await doc.set(newPayment.toFirestore());
    return doc.id;
  }

  Future<void> updatePaymentStatus(
      String id, PaymentStatus status, String? transactionId) async {
    final data = {'status': status.value};
    if (transactionId != null) data['transactionId'] = transactionId;
    await _firestore
        .collection(AppConstants.paymentsCollection)
        .doc(id)
        .update(data);
  }

  Future<void> creditSessions({
    required String ptId,
    required String memberId,
    required int sessionCount,
  }) async {
    await _firestore
        .collection(AppConstants.ptsCollection)
        .doc(ptId)
        .collection(AppConstants.membersSubCollection)
        .doc(memberId)
        .update({
      'remainingSessions': FieldValue.increment(sessionCount),
    });
  }
}
