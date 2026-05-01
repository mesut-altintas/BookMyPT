import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}

extension DateTimeX on DateTime {
  String get formattedDate => DateFormat('dd MMM yyyy', 'tr_TR').format(this);
  String get formattedTime => DateFormat('HH:mm').format(this);
  String get formattedDateTime =>
      DateFormat('dd MMM yyyy HH:mm', 'tr_TR').format(this);
  String get formattedDayMonth =>
      DateFormat('dd MMMM', 'tr_TR').format(this);
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }
}

extension StringX on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  bool get isValidPhone =>
      RegExp(r'^(\+90|0)?[0-9]{10}$').hasMatch(replaceAll(' ', ''));
  String get initials {
    final parts = trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

extension NumX on num {
  String get formattedCurrency =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(this);
  String get formattedWeight => '${toStringAsFixed(1)} kg';
}

extension ListX<T> on List<T> {
  List<T> get safeList => this;
}
