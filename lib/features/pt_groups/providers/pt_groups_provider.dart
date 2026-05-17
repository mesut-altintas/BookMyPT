import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/m_chat/providers/chat_provider.dart';
import '../../../shared/models/group_model.dart';

// ─── Stream Providers ─────────────────────────────────────────────────────────

final ptGroupsProvider =
    StreamProvider.family<List<GroupModel>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <GroupModel>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.groupsCollection)
      .where('ptId', isEqualTo: ptId)
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => GroupModel.fromFirestore(d)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      })
      .handleError((_, __) {});
});

final groupPackagesProvider =
    StreamProvider.family<List<GroupPackage>, String>((ref, groupId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <GroupPackage>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.groupPackagesCollection)
      .where('groupId', isEqualTo: groupId)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => GroupPackage.fromFirestore(d)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      })
      .handleError((_, __) {});
});

/// All active group packages visible to members (for purchase).
final allActiveGroupPackagesProvider =
    StreamProvider.family<List<GroupPackage>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <GroupPackage>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.groupPackagesCollection)
      .where('ptId', isEqualTo: ptId)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => GroupPackage.fromFirestore(d))
          .where((p) => p.isActive)
          .toList())
      .handleError((_, __) {});
});

final groupSessionsProvider =
    StreamProvider.family<List<GroupSession>, String>((ref, groupId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <GroupSession>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.groupSessionsCollection)
      .where('groupId', isEqualTo: groupId)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => GroupSession.fromFirestore(d)).toList();
        list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        return list;
      })
      .handleError((_, __) {});
});

/// Member's own group payments.
final memberGroupPaymentsProvider =
    StreamProvider.family<List<GroupPayment>, String>((ref, memberId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <GroupPayment>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.paymentsCollection)
      .where('memberId', isEqualTo: memberId)
      .snapshots()
      .map((snap) {
        final list = snap.docs
            .map((d) => GroupPayment.fromFirestore(d))
            .where((p) => p.groupId.isNotEmpty)
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      })
      .handleError((_, __) {});
});

/// PT's all group sessions (for PT calendar view).
final ptGroupSessionsProvider =
    StreamProvider.family<List<GroupSession>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <GroupSession>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.groupSessionsCollection)
      .where('ptId', isEqualTo: ptId)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => GroupSession.fromFirestore(d)).toList();
        list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return list;
      })
      .handleError((_, __) {});
});

/// All groups the member belongs to (for member calendar).
final memberGroupsProvider =
    StreamProvider.family<List<GroupModel>, String>((ref, memberId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <GroupModel>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.groupsCollection)
      .where('memberIds', arrayContains: memberId)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => GroupModel.fromFirestore(d)).toList())
      .handleError((_, __) {});
});

/// Single group by ID (used in calendar to navigate to GroupSessionScreen).
final groupByIdProvider =
    StreamProvider.family<GroupModel?, String>((ref, groupId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(null);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.groupsCollection)
      .doc(groupId)
      .snapshots()
      .map((d) => d.exists ? GroupModel.fromFirestore(d) : null)
      .handleError((_, __) {});
});

/// Member's group sessions (all groups they're in).
final memberGroupSessionsProvider =
    StreamProvider.family<List<GroupSession>, String>((ref, memberId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <GroupSession>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.groupSessionsCollection)
      .where('memberIds', arrayContains: memberId)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => GroupSession.fromFirestore(d)).toList();
        list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return list;
      })
      .handleError((_, __) {});
});

/// PT's pending group payment approvals.
final ptPendingGroupPaymentsProvider =
    StreamProvider.family<List<GroupPayment>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <GroupPayment>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.paymentsCollection)
      .where('ptId', isEqualTo: ptId)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => GroupPayment.fromFirestore(d))
          .where((p) => p.groupId.isNotEmpty && p.status == 'pending')
          .toList())
      .handleError((_, __) {});
});

// ─── Repository ───────────────────────────────────────────────────────────────

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(
    FirebaseFirestore.instance,
    ref.read(chatRepositoryProvider),
  );
});

class GroupRepository {
  const GroupRepository(this._firestore, this._chatRepo);

  final FirebaseFirestore _firestore;
  final ChatRepository _chatRepo;

  // ── Group CRUD ─────────────────────────────────────────────────────────────

  Future<String> createGroup({
    required String ptId,
    required String name,
    String? description,
    required int colorValue,
    required List<String> memberIds,
    required Map<String, String> memberNames,
  }) async {
    final ref = _firestore.collection(AppConstants.groupsCollection).doc();
    final group = GroupModel(
      id: ref.id,
      ptId: ptId,
      name: name,
      description: description,
      colorValue: colorValue,
      memberIds: memberIds,
      memberNames: memberNames,
      createdAt: DateTime.now(),
    );
    await ref.set(group.toFirestore());

    // Create/update group chat room
    await _chatRepo.createOrUpdateGroupChatRoom(
      groupId: ref.id,
      groupName: name,
      ptId: ptId,
      memberIds: memberIds,
      memberNames: memberNames,
    );

    return ref.id;
  }

  Future<void> updateGroup(GroupModel group) async {
    await _firestore
        .collection(AppConstants.groupsCollection)
        .doc(group.id)
        .update(group.toFirestore());

    // Sync group chat participants
    await _chatRepo.createOrUpdateGroupChatRoom(
      groupId: group.id,
      groupName: group.name,
      ptId: group.ptId,
      memberIds: group.memberIds,
      memberNames: group.memberNames,
    );
  }

  Future<void> deleteGroup(String groupId) async {
    // Delete group doc, packages are kept for history
    await _firestore
        .collection(AppConstants.groupsCollection)
        .doc(groupId)
        .delete();
  }

  // ── Group Package CRUD ─────────────────────────────────────────────────────

  Future<void> createGroupPackage({
    required String ptId,
    required String groupId,
    required String name,
    required int sessionCount,
    required double pricePerMember,
  }) async {
    final ref =
        _firestore.collection(AppConstants.groupPackagesCollection).doc();
    final pkg = GroupPackage(
      id: ref.id,
      ptId: ptId,
      groupId: groupId,
      name: name,
      sessionCount: sessionCount,
      pricePerMember: pricePerMember,
      isActive: true,
      createdAt: DateTime.now(),
    );
    await ref.set(pkg.toFirestore());
  }

  Future<void> deactivateGroupPackage(String packageId) async {
    await _firestore
        .collection(AppConstants.groupPackagesCollection)
        .doc(packageId)
        .update({'isActive': false});
  }

  // ── Group Payment ──────────────────────────────────────────────────────────

  Future<void> purchaseGroupPackage({
    required GroupPackage package,
    required GroupModel group,
    required String memberId,
    required String memberName,
  }) async {
    final ref = _firestore.collection(AppConstants.paymentsCollection).doc();
    final payment = GroupPayment(
      id: ref.id,
      groupId: group.id,
      groupPackageId: package.id,
      groupPackageName: package.name,
      memberId: memberId,
      memberName: memberName,
      ptId: group.ptId,
      sessionCount: package.sessionCount,
      remainingSessions: package.sessionCount,
      price: package.pricePerMember,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    await ref.set(payment.toFirestore());
  }

  Future<void> approveGroupPayment(String paymentId) async {
    await _firestore
        .collection(AppConstants.paymentsCollection)
        .doc(paymentId)
        .update({'status': 'completed'});
  }

  Future<void> rejectGroupPayment(String paymentId) async {
    await _firestore
        .collection(AppConstants.paymentsCollection)
        .doc(paymentId)
        .update({'status': 'rejected'});
  }

  // ── Group Session ──────────────────────────────────────────────────────────

  Future<String> createGroupSession({
    required String groupId,
    required String groupName,
    required String ptId,
    required DateTime dateTime,
    required int durationMinutes,
    required List<String> memberIds,
    String? notes,
  }) async {
    final ref =
        _firestore.collection(AppConstants.groupSessionsCollection).doc();
    final attendance = {for (final id in memberIds) id: false};
    final session = GroupSession(
      id: ref.id,
      groupId: groupId,
      groupName: groupName,
      ptId: ptId,
      dateTime: dateTime,
      durationMinutes: durationMinutes,
      status: 'scheduled',
      attendance: attendance,
      notes: notes,
      memberIds: memberIds,
      createdAt: DateTime.now(),
    );
    await ref.set(session.toFirestore());
    return ref.id;
  }

  Future<void> updateAttendance(
      String sessionId, Map<String, bool> attendance) async {
    await _firestore
        .collection(AppConstants.groupSessionsCollection)
        .doc(sessionId)
        .update({'attendance': attendance});
  }

  Future<void> completeGroupSession(
      String sessionId, String groupId, String ptId, Map<String, bool> attendance) async {
    final batch = _firestore.batch();

    // Mark session as completed
    batch.update(
      _firestore
          .collection(AppConstants.groupSessionsCollection)
          .doc(sessionId),
      {'status': 'completed', 'attendance': attendance},
    );

    // Decrement remaining sessions for members who attended.
    // Query by ptId (PT reads their own payments — satisfies security rule),
    // then filter by memberId / groupId / status / remainingSessions client-side.
    final allPtPayments = await _firestore
        .collection(AppConstants.paymentsCollection)
        .where('ptId', isEqualTo: ptId)
        .get();

    final attending =
        attendance.entries.where((e) => e.value).map((e) => e.key).toList();

    for (final memberId in attending) {
      final validDocs = allPtPayments.docs.where((d) {
        final data = d.data();
        return data['memberId'] == memberId &&
            data['groupId'] == groupId &&
            data['status'] == 'completed' &&
            ((data['remainingSessions'] as int?) ?? 0) > 0;
      }).toList();

      if (validDocs.isNotEmpty) {
        final doc = validDocs.first;
        final current = doc.data()['remainingSessions'] as int? ?? 0;
        batch.update(doc.reference,
            {'remainingSessions': current > 0 ? current - 1 : 0});
      }
    }

    await batch.commit();
  }

  Future<void> cancelGroupSession(String sessionId) async {
    await _firestore
        .collection(AppConstants.groupSessionsCollection)
        .doc(sessionId)
        .update({'status': 'cancelled'});
  }
}
