import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/chat_model.dart';

final chatRoomsProvider =
    StreamProvider.family<List<ChatRoom>, String>((ref, userId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <ChatRoom>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.chatsCollection)
      .where(Filter.or(
        Filter('ptId', isEqualTo: userId),
        Filter('memberId', isEqualTo: userId),
      ))
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
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <ChatMessage>[]);
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

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
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

    // Use merge so existing lastMessage/lastMessageAt/unreadCount are preserved.
    // Avoids reading a non-existent document (which would fail the read rule).
    await docRef.set({
      'id': chatId,
      'ptId': ptId,
      'memberId': memberId,
      'participants': [ptId, memberId],
      'ptName': ptName,
      'memberName': memberName,
      if (ptPhotoUrl != null) 'ptPhotoUrl': ptPhotoUrl,
      if (memberPhotoUrl != null) 'memberPhotoUrl': memberPhotoUrl,
    }, SetOptions(merge: true));

    return chatId;
  }
}
