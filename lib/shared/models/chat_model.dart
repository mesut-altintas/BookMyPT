import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool read;
  final String? imageUrl;
  final bool deletedForEveryone;
  final List<String> deletedFor;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.read = false,
    this.imageUrl,
    this.deletedForEveryone = false,
    this.deletedFor = const [],
  });

  bool get isImage => imageUrl != null;

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
      imageUrl: data['imageUrl'] as String?,
      deletedForEveryone: data['deletedForEveryone'] as bool? ?? false,
      deletedFor: List<String>.from(data['deletedFor'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'text': text,
        'createdAt': Timestamp.fromDate(createdAt),
        'read': read,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'deletedForEveryone': deletedForEveryone,
        'deletedFor': deletedFor,
      };

  ChatMessage copyWith({bool? read}) => ChatMessage(
        id: id,
        senderId: senderId,
        text: text,
        createdAt: createdAt,
        read: read ?? this.read,
        imageUrl: imageUrl,
        deletedForEveryone: deletedForEveryone,
        deletedFor: deletedFor,
      );
}

class ChatRoom {
  final String id;
  final String ptId;
  final String memberId;
  final String ptName;
  final String memberName;
  final String? ptPhotoUrl;
  final String? memberPhotoUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  // Group chat fields
  final bool isGroup;
  final String? groupId;
  final String? groupName;
  final List<String> participants;

  const ChatRoom({
    required this.id,
    required this.ptId,
    required this.memberId,
    required this.ptName,
    required this.memberName,
    this.ptPhotoUrl,
    this.memberPhotoUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isGroup = false,
    this.groupId,
    this.groupName,
    this.participants = const [],
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      ptId: data['ptId'] as String? ?? '',
      memberId: data['memberId'] as String? ?? '',
      ptName: data['ptName'] as String? ?? '',
      memberName: data['memberName'] as String? ?? '',
      ptPhotoUrl: data['ptPhotoUrl'] as String?,
      memberPhotoUrl: data['memberPhotoUrl'] as String?,
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCount: data['unreadCount'] as int? ?? 0,
      isGroup: data['isGroup'] as bool? ?? false,
      groupId: data['groupId'] as String?,
      groupName: data['groupName'] as String?,
      participants: List<String>.from(data['participants'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ptId': ptId,
        'memberId': memberId,
        'ptName': ptName,
        'memberName': memberName,
        if (ptPhotoUrl != null) 'ptPhotoUrl': ptPhotoUrl,
        if (memberPhotoUrl != null) 'memberPhotoUrl': memberPhotoUrl,
        if (lastMessage != null) 'lastMessage': lastMessage,
        if (lastMessageAt != null)
          'lastMessageAt': Timestamp.fromDate(lastMessageAt!),
        'unreadCount': unreadCount,
        'isGroup': isGroup,
        if (groupId != null) 'groupId': groupId,
        if (groupName != null) 'groupName': groupName,
        'participants': participants,
      };

  String getOtherName(String currentUserId) {
    if (isGroup) return groupName ?? 'Grup';
    return currentUserId == ptId ? memberName : ptName;
  }

  String? getOtherPhoto(String currentUserId) {
    if (isGroup) return null;
    return currentUserId == ptId ? memberPhotoUrl : ptPhotoUrl;
  }

  String get displayName => isGroup ? (groupName ?? 'Grup') : memberName;
}
