import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/progress_model.dart';

final progressListProvider =
    StreamProvider.family<List<ProgressModel>, String>((ref, memberId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <ProgressModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.progressCollection)
      .where('memberId', isEqualTo: memberId)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => ProgressModel.fromFirestore(d)).toList();
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      }).handleError((e, st) {});
});

final latestProgressProvider =
    FutureProvider.family<ProgressModel?, String>((ref, memberId) async {
  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.progressCollection)
      .where('memberId', isEqualTo: memberId)
      .get();
  if (snap.docs.isEmpty) return null;
  final list =
      snap.docs.map((d) => ProgressModel.fromFirestore(d)).toList();
  list.sort((a, b) => b.date.compareTo(a.date));
  return list.first;
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(FirebaseFirestore.instance);
});

class ProgressRepository {
  const ProgressRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<String> addProgress(ProgressModel progress) async {
    final doc =
        _firestore.collection(AppConstants.progressCollection).doc();
    final newProgress = ProgressModel(
      id: doc.id,
      memberId: progress.memberId,
      date: progress.date,
      weight: progress.weight,
      measurements: progress.measurements,
      photoUrl: progress.photoUrl,
      notes: progress.notes,
    );
    await doc.set(newProgress.toFirestore());
    return doc.id;
  }

  Future<void> deleteProgress(String id) =>
      _firestore
          .collection(AppConstants.progressCollection)
          .doc(id)
          .delete();
}
