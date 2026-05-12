import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/locale_service.dart';

final appStringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return AppStrings(locale.languageCode);
});

class AppStrings {
  final String languageCode;
  AppStrings(this.languageCode);

  bool get _en => languageCode == 'en';

  // ── Profile Screen ────────────────────────────────────────────────────────
  String get profileTitle      => _en ? 'Profile'       : 'Profil';
  String get noName            => _en ? 'No name'       : 'İsim yok';
  String get rolePt            => _en ? 'Personal Trainer' : 'Personal Trainer';
  String get roleMember        => _en ? 'Member'        : 'Üye';

  String get notifications     => _en ? 'Notifications' : 'Bildirimler';
  String get language          => _en ? 'Language'      : 'Dil';
  String get appearance        => _en ? 'Appearance'    : 'Görünüm';
  String get helpGuide         => _en ? 'User Guide'    : 'Kullanım Kılavuzu';
  String get signOut           => _en ? 'Sign Out'      : 'Çıkış Yap';

  // ── Notification Sheet ────────────────────────────────────────────────────
  String get notifSettings     => _en ? 'Notification Settings' : 'Bildirim Ayarları';
  String get notifOn           => _en ? 'Notifications On'      : 'Bildirimler Açık';
  String get notifOff          => _en ? 'Notifications Off'     : 'Bildirimler Kapalı';
  String get notifOnSub        => _en ? 'You receive appointment and session notifications'
                                      : 'Randevu ve seans bildirimleri alıyorsunuz';
  String get notifOffSub       => _en ? 'Permission required for appointment notifications'
                                      : 'Randevu ve seans bildirimleri için izin gerekli';
  String get openSystemSettings => _en ? 'Open System Settings' : 'Sistem Ayarlarını Aç';
  String get requestPermission  => _en ? 'Request Permission'   : 'İzin İste';

  // ── Theme Sheet ───────────────────────────────────────────────────────────
  String get appearanceTitle   => _en ? 'Appearance'       : 'Görünüm';
  String get themeSystem       => _en ? 'System Default'   : 'Sistem Varsayılanı';
  String get themeSystemSub    => _en ? 'Follows your device theme' : 'Cihazınızın temasını takip eder';
  String get themeLight        => _en ? 'Light Theme'      : 'Açık Tema';
  String get themeLightSub     => _en ? 'Always use light theme'   : 'Her zaman açık renk tema';
  String get themeDark         => _en ? 'Dark Theme'       : 'Koyu Tema';
  String get themeDarkSub      => _en ? 'Always use dark theme'    : 'Her zaman koyu renk tema';

  String themeModeLabel(String mode) => switch (mode) {
    'light'  => _en ? '☀️  Light'  : '☀️  Açık',
    'dark'   => _en ? '🌙  Dark'   : '🌙  Koyu',
    _        => _en ? '⚙️  System' : '⚙️  Sistem',
  };

  // ── Language Sheet ────────────────────────────────────────────────────────
  String get languageTitle     => 'Dil / Language';

  // ── Sign Out Dialog ───────────────────────────────────────────────────────
  String get signOutTitle      => _en ? 'Sign Out'                        : 'Çıkış Yap';
  String get signOutConfirm    => _en ? 'Are you sure you want to sign out?' : 'Hesabınızdan çıkmak istediğinize emin misiniz?';
  String get cancel            => _en ? 'Cancel'  : 'İptal';

  // ── Edit Name Dialog ──────────────────────────────────────────────────────
  String get editName          => _en ? 'Edit Name'    : 'İsim Düzenle';
  String get fullName          => _en ? 'Full Name'    : 'Ad Soyad';
  String get save              => _en ? 'Save'         : 'Kaydet';

  // ── Snackbars ─────────────────────────────────────────────────────────────
  String get photoUpdated      => _en ? 'Profile photo updated'    : 'Profil fotoğrafı güncellendi';
  String get photoFailed       => _en ? 'Photo could not be uploaded' : 'Fotoğraf yüklenemedi';
  String get nameUpdated       => _en ? 'Name updated'             : 'İsim güncellendi';
  String get updateFailed      => _en ? 'Could not update'         : 'Güncellenemedi';
}
