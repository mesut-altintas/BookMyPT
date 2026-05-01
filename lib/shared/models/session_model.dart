import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus { pending, confirmed, cancelled, completed }

extension SessionStatusX on SessionStatus {
  String get label {
    switch (this) {
      case SessionStatus.pending:
        return 'Bekliyor';
      case SessionStatus.confirmed:
        return 'Onaylandı';
      case SessionStatus.cancelled:
        return 'İptal Edildi';
      case SessionStatus.completed:
        return 'Tamamlandı';
    }
  }

  String get value {
    switch (this) {
      case SessionStatus.pending:
        return 'pending';
      case SessionStatus.confirmed:
        return 'confirmed';
      case SessionStatus.cancelled:
        return 'cancelled';
      case SessionStatus.completed:
        return 'completed';
    }
  }

  static SessionStatus fromString(String value) {
    switch (value) {
      case 'confirmed':
        return SessionStatus.confirmed;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'completed':
        return SessionStatus.completed;
      default:
        return SessionStatus.pending;
    }
  }
}

class SessionModel {
  final String id;
  final String ptId;
  final String memberId;
  final String memberName;
  final DateTime dateTime;
  final SessionStatus status;
  final String? notes;
  final int durationMinutes;

  const SessionModel({
    required this.id,
    required this.ptId,
    required this.memberId,
    required this.memberName,
    required this.dateTime,
    required this.status,
    this.notes,
    this.durationMinutes = 60,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      ptId: data['ptId'] as String? ?? '',
      memberId: data['memberId'] as String? ?? '',
      memberName: data['memberName'] as String? ?? '',
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: SessionStatusX.fromString(data['status'] as String? ?? 'pending'),
      notes: data['notes'] as String?,
      durationMinutes: data['durationMinutes'] as int? ?? 60,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ptId': ptId,
        'memberId': memberId,
        'memberName': memberName,
        'dateTime': Timestamp.fromDate(dateTime),
        'status': status.value,
        if (notes != null) 'notes': notes,
        'durationMinutes': durationMinutes,
      };

  SessionModel copyWith({
    String? id,
    String? ptId,
    String? memberId,
    String? memberName,
    DateTime? dateTime,
    SessionStatus? status,
    String? notes,
    int? durationMinutes,
  }) =>
      SessionModel(
        id: id ?? this.id,
        ptId: ptId ?? this.ptId,
        memberId: memberId ?? this.memberId,
        memberName: memberName ?? this.memberName,
        dateTime: dateTime ?? this.dateTime,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        durationMinutes: durationMinutes ?? this.durationMinutes,
      );
}
