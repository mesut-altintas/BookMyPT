import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/session_model.dart';
import '../../shared/models/payment_model.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.session(SessionStatus status) {
    Color color;
    switch (status) {
      case SessionStatus.pending:
        color = AppColors.pending;
        break;
      case SessionStatus.confirmed:
        color = AppColors.confirmed;
        break;
      case SessionStatus.cancelled:
        color = AppColors.cancelled;
        break;
      case SessionStatus.completed:
        color = AppColors.completed;
        break;
    }
    return StatusBadge(label: status.label, color: color);
  }

  factory StatusBadge.payment(PaymentStatus status) {
    Color color;
    switch (status) {
      case PaymentStatus.pending:
        color = AppColors.pending;
        break;
      case PaymentStatus.completed:
        color = AppColors.confirmed;
        break;
      case PaymentStatus.failed:
        color = AppColors.cancelled;
        break;
      case PaymentStatus.refunded:
        color = AppColors.info;
        break;
    }
    return StatusBadge(label: status.label, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
