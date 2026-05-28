import 'package:flutter_test/flutter_test.dart';
import 'package:bookmypt/shared/models/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('PaymentModel.fromMap', () {
    test('parses sessionDurationMinutes', () {
      final data = {
        'memberId': 'mem1',
        'ptId': 'pt1',
        'amount': 500.0,
        'status': 'pending',
        'packageName': 'Temel Paket',
        'sessionCount': 10,
        'sessionDurationMinutes': 60,
        'createdAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
      };

      final payment = PaymentModel.fromMap('pay1', data);

      expect(payment.id, 'pay1');
      expect(payment.sessionDurationMinutes, 60);
      expect(payment.sessionCount, 10);
      expect(payment.status, PaymentStatus.pending);
    });

    test('sessionDurationMinutes is null when absent', () {
      final data = {
        'memberId': 'mem1',
        'ptId': 'pt1',
        'amount': 500.0,
        'status': 'completed',
        'packageName': 'Paket',
        'sessionCount': 5,
        'createdAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
      };

      final payment = PaymentModel.fromMap('pay2', data);
      expect(payment.sessionDurationMinutes, isNull);
    });

    test('parses int duration stored as numeric', () {
      final data = {
        'memberId': 'mem1',
        'ptId': 'pt1',
        'amount': 300.0,
        'status': 'pending',
        'packageName': 'Paket 45',
        'sessionCount': 5,
        'sessionDurationMinutes': 45,
        'createdAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
      };

      final payment = PaymentModel.fromMap('pay3', data);
      expect(payment.sessionDurationMinutes, 45);
    });

    test('payment status parsing', () {
      expect(
          PaymentModel.fromMap('x', {
            'memberId': '',
            'ptId': '',
            'amount': 0,
            'status': 'completed',
            'packageName': '',
            'sessionCount': 0,
            'createdAt': Timestamp.fromDate(DateTime(2024)),
          }).status,
          PaymentStatus.completed);

      expect(
          PaymentModel.fromMap('x', {
            'memberId': '',
            'ptId': '',
            'amount': 0,
            'status': 'failed',
            'packageName': '',
            'sessionCount': 0,
            'createdAt': Timestamp.fromDate(DateTime(2024)),
          }).status,
          PaymentStatus.failed);
    });
  });

  group('PaymentModel.toFirestore', () {
    test('includes sessionDurationMinutes when set', () {
      final payment = PaymentModel(
        id: 'p1',
        memberId: 'mem1',
        ptId: 'pt1',
        amount: 500,
        status: PaymentStatus.pending,
        packageName: 'Paket',
        sessionCount: 10,
        createdAt: DateTime(2024),
        sessionDurationMinutes: 60,
      );

      final map = payment.toFirestore();
      expect(map['sessionDurationMinutes'], 60);
    });

    test('omits sessionDurationMinutes when null', () {
      final payment = PaymentModel(
        id: 'p2',
        memberId: 'mem1',
        ptId: 'pt1',
        amount: 500,
        status: PaymentStatus.pending,
        packageName: 'Paket',
        sessionCount: 10,
        createdAt: DateTime(2024),
        sessionDurationMinutes: null,
      );

      final map = payment.toFirestore();
      expect(map.containsKey('sessionDurationMinutes'), isFalse);
    });
  });
}
