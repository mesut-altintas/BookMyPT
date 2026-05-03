import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/pt_members/providers/pt_members_provider.dart';
import '../../../shared/models/invitation_model.dart';
import '../../../shared/models/member_model.dart';

// PT → Member invites (member sees these)
final memberInvitationsProvider =
    StreamProvider.autoDispose<List<InvitationModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || user.isPt) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection(AppConstants.invitationsCollection)
      .where('memberId', isEqualTo: user.uid)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snap) => snap.docs
          .map(InvitationModel.fromFirestore)
          .where((inv) => inv.type == InvitationType.invite)
          .toList())
      .handleError((_, __) {});
});

final pendingInvitationsCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(memberInvitationsProvider).valueOrNull?.length ?? 0;
});

// Member → PT requests & activation requests (PT sees these)
final ptMemberRequestsProvider =
    StreamProvider.autoDispose<List<InvitationModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || !user.isPt) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection(AppConstants.invitationsCollection)
      .where('ptId', isEqualTo: user.uid)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snap) => snap.docs
          .map(InvitationModel.fromFirestore)
          .where((inv) =>
              inv.type == InvitationType.request ||
              inv.type == InvitationType.activation)
          .toList())
      .handleError((_, __) {});
});

final ptPendingRequestsCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(ptMemberRequestsProvider).valueOrNull?.length ?? 0;
});

final invitationRepositoryProvider = Provider<InvitationRepository>((ref) {
  return InvitationRepository(FirebaseFirestore.instance);
});

class InvitationRepository {
  const InvitationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> createInvitation({
    required String ptId,
    required String ptName,
    required String memberEmail,
    String? memberId,
    String? goal,
    String? notes,
  }) async {
    final ref =
        _firestore.collection(AppConstants.invitationsCollection).doc();
    await ref.set(InvitationModel(
      id: ref.id,
      ptId: ptId,
      ptName: ptName,
      memberEmail: memberEmail,
      memberId: memberId,
      status: InvitationStatus.pending,
      type: InvitationType.invite,
      createdAt: DateTime.now(),
      goal: goal,
      notes: notes,
    ).toFirestore());
  }

  Future<void> createMemberRequest({
    required String ptId,
    required String ptName,
    required String memberId,
    required String memberName,
    required String memberEmail,
  }) async {
    final ref =
        _firestore.collection(AppConstants.invitationsCollection).doc();
    await ref.set(InvitationModel(
      id: ref.id,
      ptId: ptId,
      ptName: ptName,
      memberEmail: memberEmail,
      memberId: memberId,
      memberName: memberName,
      status: InvitationStatus.pending,
      type: InvitationType.request,
      createdAt: DateTime.now(),
    ).toFirestore());
  }

  Future<void> createActivationRequest({
    required String ptId,
    required String ptName,
    required String memberId,
    required String memberName,
    required String memberEmail,
  }) async {
    final ref =
        _firestore.collection(AppConstants.invitationsCollection).doc();
    await ref.set(InvitationModel(
      id: ref.id,
      ptId: ptId,
      ptName: ptName,
      memberEmail: memberEmail,
      memberId: memberId,
      memberName: memberName,
      status: InvitationStatus.pending,
      type: InvitationType.activation,
      createdAt: DateTime.now(),
    ).toFirestore());
  }

  Future<void> acceptInvitation({
    required InvitationModel invitation,
    required MemberRepository memberRepo,
  }) async {
    await _firestore
        .collection(AppConstants.invitationsCollection)
        .doc(invitation.id)
        .update({'status': 'accepted'});

    if (invitation.memberId != null) {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(invitation.memberId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        await memberRepo.addMember(
          ptId: invitation.ptId,
          member: MemberProfile(
            memberId: invitation.memberId!,
            name: invitation.memberName ?? data['name'] as String? ?? '',
            email: invitation.memberEmail,
            photoUrl: data['photoUrl'] as String?,
            goal: invitation.goal,
            notes: invitation.notes,
            joinedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  Future<void> rejectInvitation(String invitationId) =>
      _firestore
          .collection(AppConstants.invitationsCollection)
          .doc(invitationId)
          .update({'status': 'rejected'});
}
