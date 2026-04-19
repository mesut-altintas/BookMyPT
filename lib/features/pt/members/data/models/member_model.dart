import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberStatus { active, passive }

class MemberPackage {
  final int total;
  final int used;

  const MemberPackage({required this.total, required this.used});

  int get remaining => total - used;

  factory MemberPackage.fromMap(Map<String, dynamic> map) => MemberPackage(
        total: map['total'] ?? 0,
        used: map['used'] ?? 0,
      );

  Map<String, dynamic> toMap() => {'total': total, 'used': used, 'remaining': remaining};

  MemberPackage copyWith({int? total, int? used}) =>
      MemberPackage(total: total ?? this.total, used: used ?? this.used);
}

class MemberModel {
  final String id;
  final String trainerId;
  final String userId;
  final String name;
  final String phone;
  final MemberStatus status;
  final String accessCode;
  final MemberPackage package;
  final bool calendarAccess;

  const MemberModel({
    required this.id,
    required this.trainerId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.status,
    required this.accessCode,
    required this.package,
    this.calendarAccess = true,
  });

  factory MemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberModel(
      id: doc.id,
      trainerId: data['trainerId'] ?? '',
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      status: data['status'] == 'active' ? MemberStatus.active : MemberStatus.passive,
      accessCode: data['accessCode'] ?? '',
      package: MemberPackage.fromMap(
        (data['package'] as Map<String, dynamic>?) ?? {},
      ),
      calendarAccess: data['calendarAccess'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'trainerId': trainerId,
        'userId': userId,
        'name': name,
        'phone': phone,
        'status': status == MemberStatus.active ? 'active' : 'passive',
        'accessCode': accessCode,
        'package': package.toMap(),
        'calendarAccess': calendarAccess,
      };

  MemberModel copyWith({
    String? name,
    String? phone,
    MemberStatus? status,
    MemberPackage? package,
    bool? calendarAccess,
  }) =>
      MemberModel(
        id: id,
        trainerId: trainerId,
        userId: userId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        status: status ?? this.status,
        accessCode: accessCode,
        package: package ?? this.package,
        calendarAccess: calendarAccess ?? this.calendarAccess,
      );
}
