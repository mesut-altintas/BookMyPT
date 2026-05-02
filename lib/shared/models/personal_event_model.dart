import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalEventModel {
  final String id;
  final String memberId;
  final String title;
  final DateTime dateTime;
  final int durationMinutes;
  final String? notes;
  final DateTime createdAt;

  const PersonalEventModel({
    required this.id,
    required this.memberId,
    required this.title,
    required this.dateTime,
    required this.durationMinutes,
    this.notes,
    required this.createdAt,
  });

  factory PersonalEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PersonalEventModel(
      id: doc.id,
      memberId: data['memberId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: data['durationMinutes'] as int? ?? 60,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'memberId': memberId,
        'title': title,
        'dateTime': Timestamp.fromDate(dateTime),
        'durationMinutes': durationMinutes,
        if (notes != null) 'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
