import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Group ────────────────────────────────────────────────────────────────────

class GroupModel {
  final String id;
  final String ptId;
  final String name;
  final String? description;
  final int colorValue;
  final List<String> memberIds;
  final Map<String, String> memberNames; // {uid: displayName}
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.ptId,
    required this.name,
    this.description,
    required this.colorValue,
    required this.memberIds,
    required this.memberNames,
    required this.createdAt,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      ptId: data['ptId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      colorValue: data['colorValue'] as int? ?? 0xFF2196F3,
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      memberNames: Map<String, String>.from(
          (data['memberNames'] as Map? ?? {}).map(
              (k, v) => MapEntry(k.toString(), v.toString()))),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ptId': ptId,
        'name': name,
        if (description != null) 'description': description,
        'colorValue': colorValue,
        'memberIds': memberIds,
        'memberNames': memberNames,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  GroupModel copyWith({
    String? name,
    String? description,
    int? colorValue,
    List<String>? memberIds,
    Map<String, String>? memberNames,
  }) =>
      GroupModel(
        id: id,
        ptId: ptId,
        name: name ?? this.name,
        description: description ?? this.description,
        colorValue: colorValue ?? this.colorValue,
        memberIds: memberIds ?? this.memberIds,
        memberNames: memberNames ?? this.memberNames,
        createdAt: createdAt,
      );
}

// ─── Group Package ────────────────────────────────────────────────────────────

class GroupPackage {
  final String id;
  final String ptId;
  final String groupId;
  final String name;
  final int sessionCount;
  final double pricePerMember;
  final bool isActive;
  final DateTime createdAt;

  const GroupPackage({
    required this.id,
    required this.ptId,
    required this.groupId,
    required this.name,
    required this.sessionCount,
    required this.pricePerMember,
    required this.isActive,
    required this.createdAt,
  });

  factory GroupPackage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupPackage(
      id: doc.id,
      ptId: data['ptId'] as String? ?? '',
      groupId: data['groupId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      sessionCount: data['sessionCount'] as int? ?? 0,
      pricePerMember: (data['pricePerMember'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ptId': ptId,
        'groupId': groupId,
        'name': name,
        'sessionCount': sessionCount,
        'pricePerMember': pricePerMember,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

// ─── Group Payment ────────────────────────────────────────────────────────────

class GroupPayment {
  final String id;
  final String groupId;
  final String groupPackageId;
  final String groupPackageName;
  final String memberId;
  final String memberName;
  final String ptId;
  final int sessionCount;
  final int remainingSessions;
  final double price;
  final String status; // 'pending' | 'completed' | 'rejected'
  final DateTime createdAt;

  const GroupPayment({
    required this.id,
    required this.groupId,
    required this.groupPackageId,
    required this.groupPackageName,
    required this.memberId,
    required this.memberName,
    required this.ptId,
    required this.sessionCount,
    required this.remainingSessions,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  factory GroupPayment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupPayment(
      id: doc.id,
      groupId: data['groupId'] as String? ?? '',
      groupPackageId: data['groupPackageId'] as String? ?? '',
      groupPackageName: data['groupPackageName'] as String? ?? '',
      memberId: data['memberId'] as String? ?? '',
      memberName: data['memberName'] as String? ?? '',
      ptId: data['ptId'] as String? ?? '',
      sessionCount: data['sessionCount'] as int? ?? 0,
      remainingSessions: data['remainingSessions'] as int? ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'pending',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'groupId': groupId,
        'groupPackageId': groupPackageId,
        'groupPackageName': groupPackageName,
        'memberId': memberId,
        'memberName': memberName,
        'ptId': ptId,
        'sessionCount': sessionCount,
        'remainingSessions': remainingSessions,
        'price': price,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'isGroup': true,
      };

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
}

// ─── Group Session ────────────────────────────────────────────────────────────

class GroupSession {
  final String id;
  final String groupId;
  final String groupName;
  final String ptId;
  final DateTime dateTime;
  final int durationMinutes;
  final String status; // 'scheduled' | 'completed' | 'cancelled'
  final Map<String, bool> attendance; // {memberId: didAttend}
  final String? notes;
  final List<String> memberIds;
  final DateTime createdAt;

  const GroupSession({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.ptId,
    required this.dateTime,
    required this.durationMinutes,
    required this.status,
    required this.attendance,
    this.notes,
    required this.memberIds,
    required this.createdAt,
  });

  factory GroupSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupSession(
      id: doc.id,
      groupId: data['groupId'] as String? ?? '',
      groupName: data['groupName'] as String? ?? '',
      ptId: data['ptId'] as String? ?? '',
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: data['durationMinutes'] as int? ?? 60,
      status: data['status'] as String? ?? 'scheduled',
      attendance: Map<String, bool>.from(
          (data['attendance'] as Map? ?? {})
              .map((k, v) => MapEntry(k.toString(), v as bool))),
      notes: data['notes'] as String?,
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'groupId': groupId,
        'groupName': groupName,
        'ptId': ptId,
        'dateTime': Timestamp.fromDate(dateTime),
        'durationMinutes': durationMinutes,
        'status': status,
        'attendance': attendance,
        if (notes != null) 'notes': notes,
        'memberIds': memberIds,
        'createdAt': Timestamp.fromDate(createdAt),
        'isGroup': true,
      };

  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  int get attendedCount =>
      attendance.values.where((v) => v).length;
}
