class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'E-posta gerekli';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Geçerli bir e-posta girin';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Şifre gerekli';
    if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Şifre tekrarı gerekli';
    if (value != password) return 'Şifreler eşleşmiyor';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ad Soyad gerekli';
    if (value.trim().length < 2) return 'En az 2 karakter girin';
    return null;
  }

  static String? required(String? value, [String field = 'Bu alan']) {
    if (value == null || value.trim().isEmpty) return '$field gerekli';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final phone = value.replaceAll(' ', '');
    final phoneRegex = RegExp(r'^(\+90|0)?[0-9]{10}$');
    if (!phoneRegex.hasMatch(phone)) return 'Geçerli bir telefon numarası girin';
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Değer']) {
    if (value == null || value.isEmpty) return '$field gerekli';
    final num = double.tryParse(value);
    if (num == null) return 'Geçerli bir sayı girin';
    if (num <= 0) return '$field 0\'dan büyük olmalı';
    return null;
  }
}
