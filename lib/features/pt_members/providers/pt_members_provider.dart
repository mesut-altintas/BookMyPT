import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/member_model.dart';
import '../../../shared/models/user_model.dart';

final ptMembersProvider =
    StreamProvider.family<List<MemberProfile>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <MemberProfile>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.ptsCollection)
      .doc(ptId)
      .collection(AppConstants.membersSubCollection)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => MemberProfile.fromFirestore(d)).toList();
        list.sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
        return list;
      }).handleError((e, st) {});
});

final ptMemberDetailProvider =
    StreamProvider.family<MemberProfile?, ({String ptId, String memberId})>(
        (ref, args) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(AppConstants.ptsCollection)
      .doc(args.ptId)
      .collection(AppConstants.membersSubCollection)
      .doc(args.memberId)
      .snapshots()
      .map((d) => d.exists ? MemberProfile.fromFirestore(d) : null)
      .handleError((e, st) {});
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(FirebaseFirestore.instance);
});

class MemberRepository {
  const MemberRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> addMember({
    required String ptId,
    required MemberProfile member,
  }) async {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('[addMember] ptId=$ptId memberId=${member.memberId} authUid=$authUid');
    await _firestore
        .collection(AppConstants.ptsCollection)
        .doc(ptId)
        .collection(AppConstants.membersSubCollection)
        .doc(member.memberId)
        .set(member.toFirestore());
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(member.memberId)
          .update({'ptId': ptId});
    } catch (e) {
      debugPrint('[addMember] ptId update failed: $e');
    }
  }

  Future<void> updateMember({
    required String ptId,
    required String memberId,
    required Map<String, dynamic> data,
  }) =>
      _firestore
          .collection(AppConstants.ptsCollection)
          .doc(ptId)
          .collection(AppConstants.membersSubCollection)
          .doc(memberId)
          .update(data);

  Future<void> removeMember({
    required String ptId,
    required String memberId,
  }) async {
    debugPrint('[removeMember] START ptId=$ptId memberId=$memberId');
    await _firestore
        .collection(AppConstants.ptsCollection)
        .doc(ptId)
        .collection(AppConstants.membersSubCollection)
        .doc(memberId)
        .delete();
    debugPrint('[removeMember] subcollection deleted, clearing ptId');
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(memberId)
          .update({'ptId': ''});
      debugPrint('[removeMember] ptId cleared OK');
    } catch (e) {
      debugPrint('[removeMember] ptId clear FAILED: $e');
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final snap = await _firestore
        .collection(AppConstants.usersCollection)
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: AppConstants.roleMember)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return UserModel.fromFirestore(snap.docs.first);
  }

  Future<void> updateRemainingSessions({
    required String ptId,
    required String memberId,
    required int delta,
  }) =>
      _firestore
          .collection(AppConstants.ptsCollection)
          .doc(ptId)
          .collection(AppConstants.membersSubCollection)
          .doc(memberId)
          .update({'remainingSessions': FieldValue.increment(delta)});
}
