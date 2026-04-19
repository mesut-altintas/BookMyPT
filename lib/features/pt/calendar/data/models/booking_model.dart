import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { confirmed, cancelled, pendingCancel }

class BookingModel {
  final String id;
  final String trainerId;
  final String memberId;
  final String memberName;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final DateTime? cancelRequestedAt;

  const BookingModel({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.memberName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.cancelRequestedAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      trainerId: data['trainerId'] ?? '',
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: _parseStatus(data['status']),
      cancelRequestedAt: data['cancelRequestedAt'] != null
          ? (data['cancelRequestedAt'] as Timestamp).toDate()
          : null,
    );
  }

  static BookingStatus _parseStatus(String? s) {
    switch (s) {
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'pending_cancel':
        return BookingStatus.pendingCancel;
      default:
        return BookingStatus.confirmed;
    }
  }

  Map<String, dynamic> toFirestore() => {
        'trainerId': trainerId,
        'memberId': memberId,
        'memberName': memberName,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'status': _statusString(status),
        if (cancelRequestedAt != null)
          'cancelRequestedAt': Timestamp.fromDate(cancelRequestedAt!),
      };

  static String _statusString(BookingStatus s) {
    switch (s) {
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.pendingCancel:
        return 'pending_cancel';
      case BookingStatus.confirmed:
        return 'confirmed';
    }
  }

  BookingModel copyWith({BookingStatus? status, DateTime? cancelRequestedAt}) =>
      BookingModel(
        id: id,
        trainerId: trainerId,
        memberId: memberId,
        memberName: memberName,
        startTime: startTime,
        endTime: endTime,
        status: status ?? this.status,
        cancelRequestedAt: cancelRequestedAt ?? this.cancelRequestedAt,
      );
}
