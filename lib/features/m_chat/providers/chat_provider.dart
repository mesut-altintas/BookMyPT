import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/chat_model.dart';

/// All chat rooms where the current user is a participant.
/// Works for both 1:1 and group chats via the `participants` array field.
final chatRoomsProvider =
    StreamProvider.family<List<ChatRoom>, String>((ref, userId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <ChatRoom>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.chatsCollection)
      .where('participants', arrayContains: userId)
      .snapshots()
      .map((snap) {
        final rooms = snap.docs.map((d) => ChatRoom.fromFirestore(d)).toList();
        rooms.sort((a, b) {
          final aTime = a.lastMessageAt;
          final bTime = b.lastMessageAt;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        return rooms;
      }).handleError((e, st) {});
});

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) {
    return Stream.value(const <ChatMessage>[]);
  }
  return FirebaseFirestore.instance
      .collection(AppConstants.chatsCollection)
      .doc(chatId)
      .collection(AppConstants.messagesSubCollection)
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => ChatMessage.fromFirestore(d)).toList())
      .handleError((e, st) {});
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(FirebaseFirestore.instance);
});

class ChatRepository {
  const ChatRepository(this._firestore);

  final FirebaseFirestore _firestore;

  String getChatId(String ptId, String memberId) => '${ptId}_$memberId';
  String getGroupChatId(String groupId) => '${groupId}_group';

  // ── Delete chat room ───────────────────────────────────────────────────────

  /// Deletes the chat room document.  Messages sub-collection is left in place
  /// (Firestore does not auto-delete sub-collections) but becomes inaccessible
  /// once the parent document is gone.  Both parties lose the room from their
  /// chat list because the stream queries by the participants array.
  Future<void> deleteChatRoom(String chatId) async {
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .delete();
  }

  // ── Send message ───────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? senderName,
  }) async {
    final batch = _firestore.batch();

    final msgRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesSubCollection)
        .doc();

    final message = ChatMessage(
      id: msgRef.id,
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: DateTime.now(),
    );

    batch.set(msgRef, message.toFirestore());

    final chatRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId);

    batch.update(chatRef, {
      'lastMessage': text,
      'lastMessageAt': Timestamp.fromDate(message.createdAt),
    });

    await batch.commit();
  }

  // ── Delete message ─────────────────────────────────────────────────────────

  /// Delete only for the current user — message stays for others.
  Future<void> deleteMessageForMe(
      String chatId, String messageId, String userId) async {
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesSubCollection)
        .doc(messageId)
        .update({
      'deletedFor': FieldValue.arrayUnion([userId]),
    });
  }

  /// Delete for everyone — replaces content with deleted placeholder.
  Future<void> deleteMessageForEveryone(
      String chatId, String messageId) async {
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesSubCollection)
        .doc(messageId)
        .update({
      'deletedForEveryone': true,
      'text': '',
    });
  }

  // ── Read receipts ──────────────────────────────────────────────────────────

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final unread = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesSubCollection)
        .where('read', isEqualTo: false)
        .get();

    final others = unread.docs.where(
      (d) => (d.data()['senderId'] as String?) != userId,
    ).toList();

    if (others.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in others) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  // ── Create / get 1:1 chat room ─────────────────────────────────────────────

  Future<String> createOrGetChatRoom({
    required String ptId,
    required String memberId,
    required String ptName,
    required String memberName,
    String? ptPhotoUrl,
    String? memberPhotoUrl,
  }) async {
    final chatId = getChatId(ptId, memberId);
    final docRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId);

    await docRef.set({
      'id': chatId,
      'ptId': ptId,
      'memberId': memberId,
      'participants': [ptId, memberId],
      'ptName': ptName,
      'memberName': memberName,
      'isGroup': false,
      if (ptPhotoUrl != null) 'ptPhotoUrl': ptPhotoUrl,
      if (memberPhotoUrl != null) 'memberPhotoUrl': memberPhotoUrl,
    }, SetOptions(merge: true));

    return chatId;
  }

  // ── Create / update group chat room ───────────────────────────────────────

  Future<String> createOrUpdateGroupChatRoom({
    required String groupId,
    required String groupName,
    required String ptId,
    required List<String> memberIds,
    Map<String, String> memberNames = const {},
  }) async {
    final chatId = getGroupChatId(groupId);
    final participants = [ptId, ...memberIds];

    // Look up PT display name
    final ptDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(ptId)
        .get();
    final ptData = ptDoc.data() ?? {};
    final ptName = ptData['name'] as String? ??
        ptData['displayName'] as String? ??
        'PT';

    final participantNames = <String, String>{ptId: ptName, ...memberNames};

    final docRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId);

    await docRef.set({
      'id': chatId,
      'ptId': ptId,
      'memberId': '',
      'ptName': '',
      'memberName': '',
      'isGroup': true,
      'groupId': groupId,
      'groupName': groupName,
      'participants': participants,
      'participantNames': participantNames,
    }, SetOptions(merge: true));

    return chatId;
  }
}
