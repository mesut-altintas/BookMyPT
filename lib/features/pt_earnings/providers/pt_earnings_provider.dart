import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/payment_model.dart';

final ptPaymentsProvider =
    StreamProvider.family<List<PaymentModel>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <PaymentModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.paymentsCollection)
      .where('ptId', isEqualTo: ptId)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => PaymentModel.fromFirestore(d)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }).handleError((e, st) {});
});

final ptPackagesProvider =
    StreamProvider.family<List<PackageModel>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <PackageModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.ptsCollection)
      .doc(ptId)
      .collection(AppConstants.packagesSubCollection)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => PackageModel.fromFirestore(d)).toList())
      .handleError((e, st) {});
});

final allPtPackagesProvider =
    StreamProvider.family<List<PackageModel>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <PackageModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.ptsCollection)
      .doc(ptId)
      .collection(AppConstants.packagesSubCollection)
      .orderBy('price')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => PackageModel.fromFirestore(d)).toList())
      .handleError((e, st) {});
});

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return EarningsRepository(FirebaseFirestore.instance);
});

class EarningsRepository {
  const EarningsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<String> createPackage(PackageModel package) async {
    final doc = _firestore
        .collection(AppConstants.ptsCollection)
        .doc(package.ptId)
        .collection(AppConstants.packagesSubCollection)
        .doc();
    final newPackage = PackageModel(
      id: doc.id,
      ptId: package.ptId,
      name: package.name,
      sessionCount: package.sessionCount,
      price: package.price,
      currency: package.currency,
      description: package.description,
      isActive: package.isActive,
    );
    await doc.set(newPackage.toFirestore());
    return doc.id;
  }

  Future<void> updatePackage(
      String ptId, String packageId, Map<String, dynamic> data) =>
      _firestore
          .collection(AppConstants.ptsCollection)
          .doc(ptId)
          .collection(AppConstants.packagesSubCollection)
          .doc(packageId)
          .update(data);

  Future<void> deletePackage(String ptId, String packageId) =>
      _firestore
          .collection(AppConstants.ptsCollection)
          .doc(ptId)
          .collection(AppConstants.packagesSubCollection)
          .doc(packageId)
          .delete();
}
