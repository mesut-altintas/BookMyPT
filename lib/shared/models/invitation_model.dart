import 'package:cloud_firestore/cloud_firestore.dart';

enum InvitationStatus { pending, accepted, rejected }

extension InvitationStatusX on InvitationStatus {
  String get value => name;
}

InvitationStatus _statusFromString(String s) =>
    InvitationStatus.values.firstWhere((e) => e.name == s,
        orElse: () => InvitationStatus.pending);

class InvitationModel {
  final String id;
  final String ptId;
  final String ptName;
  final String memberEmail;
  final String? memberId;
  final InvitationStatus status;
  final DateTime createdAt;
  final String? goal;
  final String? notes;

  const InvitationModel({
    required this.id,
    required this.ptId,
    required this.ptName,
    required this.memberEmail,
    this.memberId,
    required this.status,
    required this.createdAt,
    this.goal,
    this.notes,
  });

  factory InvitationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvitationModel(
      id: doc.id,
      ptId: data['ptId'] as String? ?? '',
      ptName: data['ptName'] as String? ?? '',
      memberEmail: data['memberEmail'] as String? ?? '',
      memberId: data['memberId'] as String?,
      status: _statusFromString(data['status'] as String? ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      goal: data['goal'] as String?,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ptId': ptId,
        'ptName': ptName,
        'memberEmail': memberEmail,
        if (memberId != null) 'memberId': memberId,
        'status': status.value,
        'createdAt': Timestamp.fromDate(createdAt),
        if (goal != null) 'goal': goal,
        if (notes != null) 'notes': notes,
      };
}
