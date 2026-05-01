import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, completed, failed, refunded }

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Bekliyor';
      case PaymentStatus.completed:
        return 'Tamamlandı';
      case PaymentStatus.failed:
        return 'Başarısız';
      case PaymentStatus.refunded:
        return 'İade Edildi';
    }
  }

  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.completed:
        return 'completed';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }
}

class PackageModel {
  final String id;
  final String ptId;
  final String name;
  final int sessionCount;
  final double price;
  final String currency;
  final String? description;
  final bool isActive;

  const PackageModel({
    required this.id,
    required this.ptId,
    required this.name,
    required this.sessionCount,
    required this.price,
    this.currency = 'TRY',
    this.description,
    this.isActive = true,
  });

  factory PackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PackageModel(
      id: doc.id,
      ptId: data['ptId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      sessionCount: data['sessionCount'] as int? ?? 1,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'TRY',
      description: data['description'] as String?,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ptId': ptId,
        'name': name,
        'sessionCount': sessionCount,
        'price': price,
        'currency': currency,
        if (description != null) 'description': description,
        'isActive': isActive,
      };
}

class PaymentModel {
  final String id;
  final String memberId;
  final String ptId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String packageName;
  final int sessionCount;
  final DateTime createdAt;
  final String? transactionId;

  const PaymentModel({
    required this.id,
    required this.memberId,
    required this.ptId,
    required this.amount,
    this.currency = 'TRY',
    required this.status,
    required this.packageName,
    required this.sessionCount,
    required this.createdAt,
    this.transactionId,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      memberId: data['memberId'] as String? ?? '',
      ptId: data['ptId'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'TRY',
      status: PaymentStatusX.fromString(data['status'] as String? ?? 'pending'),
      packageName: data['packageName'] as String? ?? '',
      sessionCount: data['sessionCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionId: data['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'memberId': memberId,
        'ptId': ptId,
        'amount': amount,
        'currency': currency,
        'status': status.value,
        'packageName': packageName,
        'sessionCount': sessionCount,
        'createdAt': Timestamp.fromDate(createdAt),
        if (transactionId != null) 'transactionId': transactionId,
      };
}
