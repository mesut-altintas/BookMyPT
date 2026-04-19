import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { pt, member }

class UserModel {
  final String id;
  final UserRole role;
  final String name;
  final String phone;
  final String? fcmToken;
  // Sadece üye rolü için
  final String? memberId;
  final String? trainerId;

  const UserModel({
    required this.id,
    required this.role,
    required this.name,
    required this.phone,
    this.fcmToken,
    this.memberId,
    this.trainerId,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      role: data['role'] == 'pt' ? UserRole.pt : UserRole.member,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      fcmToken: data['fcmToken'],
      memberId: data['memberId'],
      trainerId: data['trainerId'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'role': role == UserRole.pt ? 'pt' : 'member',
        'name': name,
        'phone': phone,
        if (fcmToken != null) 'fcmToken': fcmToken,
        if (memberId != null) 'memberId': memberId,
        if (trainerId != null) 'trainerId': trainerId,
      };

  UserModel copyWith({String? name, String? fcmToken}) => UserModel(
        id: id,
        role: role,
        name: name ?? this.name,
        phone: phone,
        fcmToken: fcmToken ?? this.fcmToken,
        memberId: memberId,
        trainerId: trainerId,
      );
}
