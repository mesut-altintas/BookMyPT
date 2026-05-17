import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('tr'),
    Locale('en')
  ];

  /// Application name
  ///
  /// In tr, this message translates to:
  /// **'BookMyPT'**
  String get appName;

  /// Cancel button
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// Save button
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// Delete button
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// Confirm button
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirm;

  /// Yes
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// Continue button
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get continueText;

  /// Update button
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get update;

  /// Add button
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// Send button
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// See all link
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gör'**
  String get seeAll;

  /// All tab label
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get all;

  /// Active status
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get active;

  /// Passive status
  ///
  /// In tr, this message translates to:
  /// **'Pasif'**
  String get passive;

  /// Requests tab label
  ///
  /// In tr, this message translates to:
  /// **'İstekler'**
  String get requests;

  /// Generic error with message
  ///
  /// In tr, this message translates to:
  /// **'Hata: {message}'**
  String error(String message);

  /// Sessions unit label
  ///
  /// In tr, this message translates to:
  /// **'seans'**
  String get sessions;

  /// Minute abbreviation
  ///
  /// In tr, this message translates to:
  /// **'dk'**
  String get minuteShort;

  /// Hello greeting
  ///
  /// In tr, this message translates to:
  /// **'Merhaba, {name}!'**
  String helloName(String name);

  /// Sign in button
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get signIn;

  /// Register button
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get register;

  /// Login screen welcome title
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get welcomeTitle;

  /// Login screen subtitle
  ///
  /// In tr, this message translates to:
  /// **'Hesabınıza giriş yapın'**
  String get signInSubtitle;

  /// Email field label
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// Email field hint
  ///
  /// In tr, this message translates to:
  /// **'ornek@email.com'**
  String get emailHint;

  /// Password field label
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// Forgot password link
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPassword;

  /// Or divider between sign-in options
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get orDivider;

  /// No account prompt
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu? '**
  String get noAccount;

  /// Google sign in error
  ///
  /// In tr, this message translates to:
  /// **'Google ile giriş başarısız'**
  String get errorGoogleSignIn;

  /// User not found error
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta kayıtlı değil'**
  String get errorUserNotFound;

  /// Wrong password error
  ///
  /// In tr, this message translates to:
  /// **'Şifre hatalı'**
  String get errorWrongPassword;

  /// Invalid credential error
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı'**
  String get errorInvalidCredential;

  /// Too many requests error
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme. Lütfen bekleyin'**
  String get errorTooManyRequests;

  /// Invalid email error
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz e-posta adresi'**
  String get errorInvalidEmail;

  /// Network error
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı hatası'**
  String get errorNetworkFailed;

  /// User disabled error
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap devre dışı bırakıldı'**
  String get errorUserDisabled;

  /// Sign in failed error
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız. Lütfen tekrar deneyin'**
  String get errorSignInFailed;

  /// Register screen app bar title
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerTitle;

  /// Create account heading
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get createAccount;

  /// Register screen subtitle
  ///
  /// In tr, this message translates to:
  /// **'Bilgilerinizi girerek devam edin'**
  String get enterInfoToContinue;

  /// Full name field label
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get fullName;

  /// Full name field hint
  ///
  /// In tr, this message translates to:
  /// **'Ali Yılmaz'**
  String get fullNameHint;

  /// Password field hint
  ///
  /// In tr, this message translates to:
  /// **'En az 6 karakter'**
  String get passwordHint;

  /// Confirm password field label
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get confirmPassword;

  /// Confirm password hint
  ///
  /// In tr, this message translates to:
  /// **'Şifrenizi tekrar girin'**
  String get confirmPasswordHint;

  /// Already have account prompt
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı? '**
  String get alreadyHaveAccount;

  /// Email already in use error
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta zaten kayıtlı'**
  String get errorEmailInUse;

  /// Weak password error
  ///
  /// In tr, this message translates to:
  /// **'Şifre çok zayıf'**
  String get errorWeakPassword;

  /// Register failed error
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarısız. Lütfen tekrar deneyin'**
  String get errorRegisterFailed;

  /// Forgot password screen title
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPasswordTitle;

  /// Reset password heading
  ///
  /// In tr, this message translates to:
  /// **'Şifre Sıfırlama'**
  String get resetPassword;

  /// Reset password subtitle
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinize sıfırlama bağlantısı göndereceğiz'**
  String get resetPasswordSubtitle;

  /// Send reset link button
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama Bağlantısı Gönder'**
  String get sendResetLink;

  /// Email sent title
  ///
  /// In tr, this message translates to:
  /// **'E-posta Gönderildi'**
  String get emailSent;

  /// Email sent confirmation message
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine şifre sıfırlama bağlantısı gönderildi'**
  String emailSentMessage(String email);

  /// Back to login button
  ///
  /// In tr, this message translates to:
  /// **'Giriş Sayfasına Dön'**
  String get backToLogin;

  /// Role selection title
  ///
  /// In tr, this message translates to:
  /// **'Rolünüzü Seçin'**
  String get selectRole;

  /// Role selection subtitle
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı nasıl kullanacaksınız?'**
  String get howToUseApp;

  /// PT role title
  ///
  /// In tr, this message translates to:
  /// **'Personal Trainer'**
  String get rolePtTitle;

  /// PT role subtitle
  ///
  /// In tr, this message translates to:
  /// **'Üyelerinizi yönetin, program oluşturun ve takvim tutun'**
  String get rolePtSubtitle;

  /// Member role title
  ///
  /// In tr, this message translates to:
  /// **'Üye'**
  String get roleMemberTitle;

  /// Member role subtitle
  ///
  /// In tr, this message translates to:
  /// **'PT\'nizin programını görün, randevu alın ve ilerlemenizi takip edin'**
  String get roleMemberSubtitle;

  /// Navigation: Home
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// Navigation: Calendar
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get navCalendar;

  /// Navigation: Programs
  ///
  /// In tr, this message translates to:
  /// **'Program'**
  String get navPrograms;

  /// Navigation: Progress
  ///
  /// In tr, this message translates to:
  /// **'İlerleme'**
  String get navProgress;

  /// Navigation: Packages
  ///
  /// In tr, this message translates to:
  /// **'Paketler'**
  String get navPackages;

  /// Navigation: Chat
  ///
  /// In tr, this message translates to:
  /// **'Mesaj'**
  String get navChat;

  /// Navigation: Dashboard (PT)
  ///
  /// In tr, this message translates to:
  /// **'Panel'**
  String get navDashboard;

  /// Navigation: Members (PT)
  ///
  /// In tr, this message translates to:
  /// **'Üyeler'**
  String get navMembers;

  /// Navigation: Earnings (PT)
  ///
  /// In tr, this message translates to:
  /// **'Gelir'**
  String get navEarnings;

  /// Upcoming sessions section title
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan Seanslar'**
  String get upcomingSessions;

  /// Empty upcoming sessions message
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan seans yok'**
  String get noUpcomingSessions;

  /// Recent members section title
  ///
  /// In tr, this message translates to:
  /// **'Son Üyeler'**
  String get recentMembers;

  /// Empty members message in dashboard
  ///
  /// In tr, this message translates to:
  /// **'Henüz üye yok'**
  String get noMembersYet;

  /// Add session FAB label
  ///
  /// In tr, this message translates to:
  /// **'Seans Ekle'**
  String get addSession;

  /// Total members stat card
  ///
  /// In tr, this message translates to:
  /// **'Toplam Üye'**
  String get totalMembers;

  /// This week stat card
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get thisWeek;

  /// Goal not set placeholder
  ///
  /// In tr, this message translates to:
  /// **'Hedef belirtilmemiş'**
  String get goalNotSet;

  /// Upcoming appointments section
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan Randevular'**
  String get upcomingAppointments;

  /// Empty upcoming appointments
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan randevu yok'**
  String get noUpcomingAppointments;

  /// Book appointment action
  ///
  /// In tr, this message translates to:
  /// **'Randevu Al'**
  String get bookAppointment;

  /// Latest progress section title
  ///
  /// In tr, this message translates to:
  /// **'Son İlerleme'**
  String get latestProgress;

  /// No progress record message
  ///
  /// In tr, this message translates to:
  /// **'İlerleme kaydı yok'**
  String get noProgressRecord;

  /// Record progress action
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get recordProgress;

  /// My trainer label
  ///
  /// In tr, this message translates to:
  /// **'Eğitmeniniz'**
  String get myTrainer;

  /// Trainer load error
  ///
  /// In tr, this message translates to:
  /// **'Eğitmen yüklenemedi'**
  String get trainerNotLoaded;

  /// Trainer info not found
  ///
  /// In tr, this message translates to:
  /// **'Eğitmen bilgisi bulunamadı'**
  String get trainerInfoNotFound;

  /// Leave trainer button
  ///
  /// In tr, this message translates to:
  /// **'Üyeliği Bırak'**
  String get leaveTrainer;

  /// Leave trainer dialog title
  ///
  /// In tr, this message translates to:
  /// **'Üyeliği Bırak'**
  String get leaveTrainerTitle;

  /// Leave trainer confirmation message
  ///
  /// In tr, this message translates to:
  /// **'{ptName} ile üyeliğinizi sonlandırmak istiyor musunuz?'**
  String leaveTrainerConfirm(String ptName);

  /// Remaining sessions warning
  ///
  /// In tr, this message translates to:
  /// **'{count} kalan seansınız bulunuyor.'**
  String remainingSessionsWarning(int count);

  /// Yes leave button
  ///
  /// In tr, this message translates to:
  /// **'Evet, Bırak'**
  String get yesLeave;

  /// No PT assigned banner title
  ///
  /// In tr, this message translates to:
  /// **'PT Atanmamış'**
  String get noPtAssigned;

  /// Find PT banner subtitle
  ///
  /// In tr, this message translates to:
  /// **'PT bularak antrenmanlarınıza başlayabilirsiniz'**
  String get findPtBannerSub;

  /// Find PT button
  ///
  /// In tr, this message translates to:
  /// **'PT Bul'**
  String get findPt;

  /// My programs quick action label
  ///
  /// In tr, this message translates to:
  /// **'Programım'**
  String get myPrograms;

  /// Last weight label
  ///
  /// In tr, this message translates to:
  /// **'Son kilo'**
  String get lastWeight;

  /// My members screen title
  ///
  /// In tr, this message translates to:
  /// **'Üyelerim'**
  String get myMembers;

  /// Search member hint
  ///
  /// In tr, this message translates to:
  /// **'Üye ara...'**
  String get searchMember;

  /// No members yet full message
  ///
  /// In tr, this message translates to:
  /// **'Henüz üyeniz yok'**
  String get noMembersYetFull;

  /// Add member hint
  ///
  /// In tr, this message translates to:
  /// **'Üye eklemek için + butonuna tıklayın'**
  String get addMemberHint;

  /// Add member button
  ///
  /// In tr, this message translates to:
  /// **'Üye Ekle'**
  String get addMember;

  /// No search results
  ///
  /// In tr, this message translates to:
  /// **'Arama sonucu bulunamadı'**
  String get searchNoResult;

  /// Member not found message
  ///
  /// In tr, this message translates to:
  /// **'Üye bulunamadı'**
  String get memberNotFound;

  /// Send message action
  ///
  /// In tr, this message translates to:
  /// **'Mesaj Gönder'**
  String get sendMessage;

  /// Chat open error
  ///
  /// In tr, this message translates to:
  /// **'Mesaj açılamadı: {error}'**
  String chatOpenError(String error);

  /// Add member screen title
  ///
  /// In tr, this message translates to:
  /// **'Üye Ekle'**
  String get addMemberTitle;

  /// Member email field
  ///
  /// In tr, this message translates to:
  /// **'Üye E-posta'**
  String get memberEmail;

  /// Goal field
  ///
  /// In tr, this message translates to:
  /// **'Hedef'**
  String get goal;

  /// Goal field hint
  ///
  /// In tr, this message translates to:
  /// **'Kilo vermek, kas yapmak...'**
  String get goalHint;

  /// Notes field
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get notes;

  /// Invitation sent message
  ///
  /// In tr, this message translates to:
  /// **'{name} adresine davet gönderildi'**
  String invitationSent(String name);

  /// Member not found by email
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta ile kayıtlı üye bulunamadı. Önce üye kayıt olmalıdır.'**
  String get memberNotFoundByEmail;

  /// PT Calendar screen title
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get calendarTitle;

  /// Session detail title
  ///
  /// In tr, this message translates to:
  /// **'Seans Detayı'**
  String get sessionDetailTitle;

  /// Delete session option
  ///
  /// In tr, this message translates to:
  /// **'Seansı Sil'**
  String get deleteSession;

  /// Delete session confirmation
  ///
  /// In tr, this message translates to:
  /// **'Bu seansı silmek istiyor musunuz?'**
  String get deleteSessionConfirm;

  /// Delete error dialog title
  ///
  /// In tr, this message translates to:
  /// **'Silme Hatası'**
  String get deleteError;

  /// Close button
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// My appointments screen title
  ///
  /// In tr, this message translates to:
  /// **'Randevularım'**
  String get myAppointments;

  /// Calendar tab
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get tabCalendar;

  /// History tab
  ///
  /// In tr, this message translates to:
  /// **'Geçmişim'**
  String get tabHistory;

  /// Request appointment button
  ///
  /// In tr, this message translates to:
  /// **'Randevu Talep Et'**
  String get requestAppointment;

  /// No appointment for today
  ///
  /// In tr, this message translates to:
  /// **'Bu gün randevu yok'**
  String get noDayAppointment;

  /// Appointments count label
  ///
  /// In tr, this message translates to:
  /// **'{count} randevum'**
  String appointmentsCount(int count);

  /// Session duration in minutes
  ///
  /// In tr, this message translates to:
  /// **'{count} dk seans'**
  String sessionDurationMin(int count);

  /// PT busy label
  ///
  /// In tr, this message translates to:
  /// **'PT dolu'**
  String get ptBusy;

  /// PT personal busy label
  ///
  /// In tr, this message translates to:
  /// **'PT meşgul'**
  String get ptBusyPersonal;

  /// Personal activity label
  ///
  /// In tr, this message translates to:
  /// **'Kişisel etkinlik'**
  String get personalActivity;

  /// Passive member dialog title
  ///
  /// In tr, this message translates to:
  /// **'Pasif Üye'**
  String get passiveMemberTitle;

  /// Passive member dialog content
  ///
  /// In tr, this message translates to:
  /// **'Randevu alabilmek için aktif olmanız gerekiyor. Eğitmeninize aktivasyon isteği göndermek ister misiniz?'**
  String get passiveMemberContent;

  /// Send request button
  ///
  /// In tr, this message translates to:
  /// **'İstek Gönder'**
  String get sendRequest;

  /// Activation request sent snackbar
  ///
  /// In tr, this message translates to:
  /// **'Aktivasyon isteği gönderildi'**
  String get activationRequestSent;

  /// Date and time field label
  ///
  /// In tr, this message translates to:
  /// **'Tarih ve Saat'**
  String get dateAndTime;

  /// Time conflict error
  ///
  /// In tr, this message translates to:
  /// **'Bu saatte zaten randevunuz var'**
  String get timeConflict;

  /// PT not available error
  ///
  /// In tr, this message translates to:
  /// **'PT bu saatte müsait değil'**
  String get ptNotAvailable;

  /// Session duration label with value
  ///
  /// In tr, this message translates to:
  /// **'Seans süresi: {count} dk'**
  String sessionDurationLabel(int count);

  /// Duration field label
  ///
  /// In tr, this message translates to:
  /// **'Süre (dk):'**
  String get durationLabel;

  /// Find PT by email instruction
  ///
  /// In tr, this message translates to:
  /// **'PT\'nizi bulmak için e-posta adresini girin'**
  String get findPtEnterEmail;

  /// PT email field label
  ///
  /// In tr, this message translates to:
  /// **'PT E-posta'**
  String get ptEmail;

  /// Link PT button
  ///
  /// In tr, this message translates to:
  /// **'PT\'yi Bağla'**
  String get linkPt;

  /// PT not found by email error
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta ile kayıtlı PT bulunamadı'**
  String get ptNotFoundByEmail;

  /// Edit appointment sheet title
  ///
  /// In tr, this message translates to:
  /// **'Randevu Düzenle'**
  String get editAppointment;

  /// Edit restriction note
  ///
  /// In tr, this message translates to:
  /// **'Sadece bekleyen talepler düzenlenebilir'**
  String get onlyPendingCanEdit;

  /// Completed sessions label
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan'**
  String get completedCount;

  /// Total duration label
  ///
  /// In tr, this message translates to:
  /// **'Toplam süre'**
  String get totalDuration;

  /// Upcoming sessions history tab header
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan Seanslarım'**
  String get upcomingMySessions;

  /// Completed sessions history tab header
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan Seanslar'**
  String get completedSessions;

  /// No completed sessions message
  ///
  /// In tr, this message translates to:
  /// **'Henüz tamamlanan seans yok'**
  String get noCompletedSessions;

  /// No completed sessions sub-message
  ///
  /// In tr, this message translates to:
  /// **'Onaylanan seanslarınız tamamlandıkça burada görünecek'**
  String get noCompletedSessionsSub;

  /// Booking confirm screen title
  ///
  /// In tr, this message translates to:
  /// **'Randevu Onayla'**
  String get bookingConfirmTitle;

  /// Appointment details card title
  ///
  /// In tr, this message translates to:
  /// **'Randevu Detayları'**
  String get appointmentDetails;

  /// Waiting for PT approval note
  ///
  /// In tr, this message translates to:
  /// **'Randevunuz PT\'niz tarafından onaylanmayı bekleyecektir.'**
  String get waitingPtApproval;

  /// Go to my appointments button
  ///
  /// In tr, this message translates to:
  /// **'Randevularıma Git'**
  String get goToMyAppointments;

  /// Add personal event title
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Etkinlik Ekle'**
  String get addPersonalEvent;

  /// Event title field
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get eventTitle;

  /// Event title hint
  ///
  /// In tr, this message translates to:
  /// **'Yoga, antrenman...'**
  String get eventTitleHint;

  /// Member calendar screen title
  ///
  /// In tr, this message translates to:
  /// **'Takvimim'**
  String get memberCalendarTitle;

  /// Progress screen title
  ///
  /// In tr, this message translates to:
  /// **'İlerleme Takibi'**
  String get progressTitle;

  /// No progress records yet
  ///
  /// In tr, this message translates to:
  /// **'Henüz ilerleme kaydı yok'**
  String get noProgressYet;

  /// Add measurements subtitle
  ///
  /// In tr, this message translates to:
  /// **'Kilo ve ölçü bilgilerinizi kaydedin'**
  String get addMeasurements;

  /// Add record button
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ekle'**
  String get addRecord;

  /// Weight chart title
  ///
  /// In tr, this message translates to:
  /// **'Kilo Grafiği'**
  String get weightChart;

  /// Add progress screen title
  ///
  /// In tr, this message translates to:
  /// **'İlerleme Ekle'**
  String get addProgressTitle;

  /// Progress saved snackbar
  ///
  /// In tr, this message translates to:
  /// **'İlerleme kaydedildi'**
  String get progressSaved;

  /// Saving loading message
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor...'**
  String get saving;

  /// Add progress photo button
  ///
  /// In tr, this message translates to:
  /// **'İlerleme Fotoğrafı Ekle'**
  String get addProgressPhoto;

  /// At least one measurement required
  ///
  /// In tr, this message translates to:
  /// **'En az bir ölçüm girin'**
  String get enterAtLeastOneMeasurement;

  /// Weight field
  ///
  /// In tr, this message translates to:
  /// **'Kilo (kg)'**
  String get weight;

  /// Chest measurement field
  ///
  /// In tr, this message translates to:
  /// **'Göğüs (cm)'**
  String get chest;

  /// Waist measurement field
  ///
  /// In tr, this message translates to:
  /// **'Bel (cm)'**
  String get waist;

  /// Hips measurement field
  ///
  /// In tr, this message translates to:
  /// **'Kalça (cm)'**
  String get hips;

  /// Bicep measurement field
  ///
  /// In tr, this message translates to:
  /// **'Biceps (cm)'**
  String get bicep;

  /// Thigh measurement field
  ///
  /// In tr, this message translates to:
  /// **'Uyluk (cm)'**
  String get thigh;

  /// Body fat field
  ///
  /// In tr, this message translates to:
  /// **'Yağ Oranı (%)'**
  String get bodyFat;

  /// Date field
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get date;

  /// Chat list screen title
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get messagesTitle;

  /// No messages yet
  ///
  /// In tr, this message translates to:
  /// **'Henüz mesajınız yok'**
  String get noMessagesYet;

  /// Start messaging subtitle
  ///
  /// In tr, this message translates to:
  /// **'PT\'niz veya üyeniz ile mesajlaşmaya başlayın'**
  String get startMessaging;

  /// Type message hint
  ///
  /// In tr, this message translates to:
  /// **'Mesaj yaz...'**
  String get typeMessage;

  /// Earnings screen title
  ///
  /// In tr, this message translates to:
  /// **'Gelir Takibi'**
  String get earningsTitle;

  /// Package management title
  ///
  /// In tr, this message translates to:
  /// **'Paket Yönetimi'**
  String get packageManagement;

  /// Total earnings label
  ///
  /// In tr, this message translates to:
  /// **'Toplam Gelir'**
  String get totalEarnings;

  /// Pending payments section
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen Ödemeler'**
  String get pendingPayments;

  /// Completed payments section
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan Ödemeler'**
  String get completedPayments;

  /// No earnings yet
  ///
  /// In tr, this message translates to:
  /// **'Henüz gelir kaydı yok'**
  String get noEarningsYet;

  /// Payment screen title
  ///
  /// In tr, this message translates to:
  /// **'Ödeme'**
  String get paymentTitle;

  /// Payment history screen title
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Geçmişi'**
  String get paymentHistoryTitle;

  /// No payments yet
  ///
  /// In tr, this message translates to:
  /// **'Henüz ödeme yok'**
  String get noPaymentsYet;

  /// Program list screen title
  ///
  /// In tr, this message translates to:
  /// **'Programlar'**
  String get programListTitle;

  /// No programs yet
  ///
  /// In tr, this message translates to:
  /// **'Henüz program oluşturulmamış'**
  String get noProgramsYet;

  /// Create program button
  ///
  /// In tr, this message translates to:
  /// **'Program Oluştur'**
  String get createProgram;

  /// Program detail screen title
  ///
  /// In tr, this message translates to:
  /// **'Program Detayı'**
  String get programDetailTitle;

  /// Assign to member button
  ///
  /// In tr, this message translates to:
  /// **'Üyeye Ata'**
  String get assignToMember;

  /// Member programs screen title
  ///
  /// In tr, this message translates to:
  /// **'Programlarım'**
  String get memberProgramsTitle;

  /// No program assigned message
  ///
  /// In tr, this message translates to:
  /// **'Henüz program atanmamış'**
  String get noProgramAssigned;

  /// Workout detail screen title
  ///
  /// In tr, this message translates to:
  /// **'Antrenman Detayı'**
  String get workoutDetailTitle;

  /// Invitation list screen title
  ///
  /// In tr, this message translates to:
  /// **'Davetler'**
  String get invitationListTitle;

  /// No pending invitations
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen davet yok'**
  String get noPendingInvitations;

  /// Accept button
  ///
  /// In tr, this message translates to:
  /// **'Kabul Et'**
  String get accept;

  /// Reject button
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get reject;

  /// Find PT screen title
  ///
  /// In tr, this message translates to:
  /// **'PT Bul'**
  String get findPtTitle;

  /// Search PT hint
  ///
  /// In tr, this message translates to:
  /// **'PT ara...'**
  String get searchPt;

  /// No PT found
  ///
  /// In tr, this message translates to:
  /// **'PT bulunamadı'**
  String get noPtFound;

  /// Profile screen title
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No name placeholder
  ///
  /// In tr, this message translates to:
  /// **'İsim yok'**
  String get noName;

  /// PT role label on profile
  ///
  /// In tr, this message translates to:
  /// **'Personal Trainer'**
  String get rolePt;

  /// Member role label on profile
  ///
  /// In tr, this message translates to:
  /// **'Üye'**
  String get roleMember;

  /// Notifications menu item
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// Language menu item
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// Appearance menu item
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get appearance;

  /// Help guide menu item
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Kılavuzu'**
  String get helpGuide;

  /// Sign out menu item
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get signOut;

  /// Notification settings sheet title
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get notifSettings;

  /// Notifications on status
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler Açık'**
  String get notifOn;

  /// Notifications off status
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler Kapalı'**
  String get notifOff;

  /// Notifications on subtitle
  ///
  /// In tr, this message translates to:
  /// **'Randevu ve seans bildirimleri alıyorsunuz'**
  String get notifOnSub;

  /// Notifications off subtitle
  ///
  /// In tr, this message translates to:
  /// **'Randevu ve seans bildirimleri için izin gerekli'**
  String get notifOffSub;

  /// Open system settings button
  ///
  /// In tr, this message translates to:
  /// **'Sistem Ayarlarını Aç'**
  String get openSystemSettings;

  /// Request permission button
  ///
  /// In tr, this message translates to:
  /// **'İzin İste'**
  String get requestPermission;

  /// Appearance sheet title
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get appearanceTitle;

  /// System theme option
  ///
  /// In tr, this message translates to:
  /// **'Sistem Varsayılanı'**
  String get themeSystem;

  /// System theme subtitle
  ///
  /// In tr, this message translates to:
  /// **'Cihazınızın temasını takip eder'**
  String get themeSystemSub;

  /// Light theme option
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get themeLight;

  /// Light theme subtitle
  ///
  /// In tr, this message translates to:
  /// **'Her zaman açık renk tema'**
  String get themeLightSub;

  /// Dark theme option
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get themeDark;

  /// Dark theme subtitle
  ///
  /// In tr, this message translates to:
  /// **'Her zaman koyu renk tema'**
  String get themeDarkSub;

  /// Light theme chip label
  ///
  /// In tr, this message translates to:
  /// **'☀️  Açık'**
  String get themeLabelLight;

  /// Dark theme chip label
  ///
  /// In tr, this message translates to:
  /// **'🌙  Koyu'**
  String get themeLabelDark;

  /// System theme chip label
  ///
  /// In tr, this message translates to:
  /// **'⚙️  Sistem'**
  String get themeLabelSystem;

  /// Language sheet title
  ///
  /// In tr, this message translates to:
  /// **'Dil / Language'**
  String get languageTitle;

  /// Sign out dialog title
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get signOutTitle;

  /// Sign out confirmation message
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızdan çıkmak istediğinize emin misiniz?'**
  String get signOutConfirm;

  /// Edit name dialog title
  ///
  /// In tr, this message translates to:
  /// **'İsim Düzenle'**
  String get editName;

  /// Photo updated snackbar
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı güncellendi'**
  String get photoUpdated;

  /// Photo upload failed snackbar
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf yüklenemedi'**
  String get photoFailed;

  /// Name updated snackbar
  ///
  /// In tr, this message translates to:
  /// **'İsim güncellendi'**
  String get nameUpdated;

  /// Update failed snackbar
  ///
  /// In tr, this message translates to:
  /// **'Güncellenemedi'**
  String get updateFailed;

  /// Chat screen fallback title
  ///
  /// In tr, this message translates to:
  /// **'Mesajlaşma'**
  String get messaging;

  /// Empty chat placeholder
  ///
  /// In tr, this message translates to:
  /// **'Henüz mesaj yok.\nMerhaba diyerek başlayın!'**
  String get chatEmptyMessage;

  /// Message send failed error
  ///
  /// In tr, this message translates to:
  /// **'Gönderilemedi: {error}'**
  String sendFailed(String error);

  /// No events today placeholder
  ///
  /// In tr, this message translates to:
  /// **'Bu gün etkinlik yok'**
  String get noEventToday;

  /// Add session bottom sheet subtitle
  ///
  /// In tr, this message translates to:
  /// **'Üye ile antrenman seansı planla'**
  String get addSessionSubtitle;

  /// Add personal event subtitle (PT)
  ///
  /// In tr, this message translates to:
  /// **'Antrenman, not veya hatırlatıcı ekle'**
  String get addPersonalEventSubtitle;

  /// Add personal event subtitle (member)
  ///
  /// In tr, this message translates to:
  /// **'Antrenman, not veya hatırlatıcı ekleyin'**
  String get addPersonalEventSubtitleMember;

  /// Create session button
  ///
  /// In tr, this message translates to:
  /// **'Seans Oluştur'**
  String get createSession;

  /// Event conflict error
  ///
  /// In tr, this message translates to:
  /// **'Bu saatte çakışan etkinlik var'**
  String get eventConflict;

  /// Session conflict error in personal event
  ///
  /// In tr, this message translates to:
  /// **'Bu saatte çakışan seans var'**
  String get sessionConflict;

  /// Select member hint
  ///
  /// In tr, this message translates to:
  /// **'Üye Seç'**
  String get selectMember;

  /// Member label
  ///
  /// In tr, this message translates to:
  /// **'Üye'**
  String get member;

  /// Time field label
  ///
  /// In tr, this message translates to:
  /// **'Saat'**
  String get time;

  /// Appointment request list tile title
  ///
  /// In tr, this message translates to:
  /// **'Randevu Talebi'**
  String get appointmentRequest;

  /// Appointment request subtitle
  ///
  /// In tr, this message translates to:
  /// **'Eğitmeninizden randevu isteyin'**
  String get appointmentRequestSub;

  /// No events for selected day
  ///
  /// In tr, this message translates to:
  /// **'Bu gün için etkinlik yok'**
  String get noEventForDay;

  /// PT appointment tile title
  ///
  /// In tr, this message translates to:
  /// **'PT Randevusu'**
  String get ptAppointment;

  /// Session confirmed status
  ///
  /// In tr, this message translates to:
  /// **'Onaylandı'**
  String get statusConfirmed;

  /// Session pending status
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get statusPending;

  /// Session completed status
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get statusCompleted;

  /// Edit event screen title
  ///
  /// In tr, this message translates to:
  /// **'Etkinliği Düzenle'**
  String get editEvent;

  /// Add event screen title
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik Ekle'**
  String get addEvent;

  /// Title required validation message
  ///
  /// In tr, this message translates to:
  /// **'Başlık gerekli'**
  String get titleRequired;

  /// Duration section label
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get duration;

  /// Notes optional field label
  ///
  /// In tr, this message translates to:
  /// **'Notlar (İsteğe bağlı)'**
  String get notesOptional;

  /// Set member passive action
  ///
  /// In tr, this message translates to:
  /// **'Pasif Yap'**
  String get setPassive;

  /// Set member active action
  ///
  /// In tr, this message translates to:
  /// **'Aktif Yap'**
  String get setActive;

  /// Remove member dialog title
  ///
  /// In tr, this message translates to:
  /// **'Üyeyi Sil'**
  String get removeMember;

  /// Overview tab label
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakış'**
  String get overview;

  /// Programs tab label
  ///
  /// In tr, this message translates to:
  /// **'Programlar'**
  String get programs;

  /// Sessions tab label
  ///
  /// In tr, this message translates to:
  /// **'Seanslar'**
  String get sessionsTab;

  /// Not specified placeholder
  ///
  /// In tr, this message translates to:
  /// **'Belirtilmemiş'**
  String get notSpecified;

  /// Join date label
  ///
  /// In tr, this message translates to:
  /// **'Katılım Tarihi'**
  String get joinDate;

  /// Starting weight label
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Kilosu'**
  String get startingWeightLabel;

  /// Height label
  ///
  /// In tr, this message translates to:
  /// **'Boy'**
  String get heightLabel;

  /// Phone label
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// Body measurements section title
  ///
  /// In tr, this message translates to:
  /// **'Vücut Ölçüleri (cm)'**
  String get bodyMeasurements;

  /// Leg measurement field
  ///
  /// In tr, this message translates to:
  /// **'Bacak'**
  String get leg;

  /// Arm/bicep measurement field
  ///
  /// In tr, this message translates to:
  /// **'Kol (bicep)'**
  String get armBicep;

  /// My packages screen title
  ///
  /// In tr, this message translates to:
  /// **'Paketlerim'**
  String get myPackages;

  /// Pending approval section header
  ///
  /// In tr, this message translates to:
  /// **'Onay Bekliyor'**
  String get pendingApproval;

  /// Recent transactions section header
  ///
  /// In tr, this message translates to:
  /// **'Son İşlemler'**
  String get recentTransactions;

  /// Remaining session rights label
  ///
  /// In tr, this message translates to:
  /// **'kalan seans hakkı'**
  String get remainingSessionRights;

  /// No PT packages subtitle
  ///
  /// In tr, this message translates to:
  /// **'PT\'niz sizi sisteme ekledikten sonra paketleri görebilirsiniz'**
  String get noPtPackagesSub;

  /// Buy package section header
  ///
  /// In tr, this message translates to:
  /// **'Paket Satın Al'**
  String get buyPackage;

  /// Purchase button
  ///
  /// In tr, this message translates to:
  /// **'Satın Al'**
  String get purchase;

  /// Payment request created snackbar
  ///
  /// In tr, this message translates to:
  /// **'Ödeme talebiniz oluşturuldu. PT\'niz onayladığında seans hakkınız yüklenecektir.'**
  String get paymentRequestCreated;

  /// No packages yet message
  ///
  /// In tr, this message translates to:
  /// **'Henüz paket oluşturmadınız'**
  String get noPackagesYet;

  /// No packages yet subtitle
  ///
  /// In tr, this message translates to:
  /// **'Üyeleriniz için seans paketi oluşturun'**
  String get noPackagesYetSub;

  /// Add package button
  ///
  /// In tr, this message translates to:
  /// **'Paket Ekle'**
  String get addPackage;

  /// Edit package sheet title
  ///
  /// In tr, this message translates to:
  /// **'Paketi Düzenle'**
  String get editPackage;

  /// New package sheet title
  ///
  /// In tr, this message translates to:
  /// **'Yeni Paket'**
  String get newPackage;

  /// Package name field
  ///
  /// In tr, this message translates to:
  /// **'Paket Adı'**
  String get packageName;

  /// Session count field label
  ///
  /// In tr, this message translates to:
  /// **'Seans Sayısı'**
  String get sessionCountLabel;

  /// Session duration label
  ///
  /// In tr, this message translates to:
  /// **'Seans Süresi'**
  String get sessionDuration;

  /// Price in TRY field label
  ///
  /// In tr, this message translates to:
  /// **'Fiyat (TRY)'**
  String get priceTry;

  /// Description optional field label
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (İsteğe bağlı)'**
  String get descriptionOptional;

  /// Member specific package toggle label
  ///
  /// In tr, this message translates to:
  /// **'Üyeye özel paket'**
  String get memberSpecificPackage;

  /// Create package button
  ///
  /// In tr, this message translates to:
  /// **'Paketi Oluştur'**
  String get createPackage;

  /// Delete package dialog title
  ///
  /// In tr, this message translates to:
  /// **'Paketi Sil'**
  String get deletePackageTitle;

  /// Delete package confirmation
  ///
  /// In tr, this message translates to:
  /// **'Bu paketi silmek istiyor musunuz?'**
  String get deletePackageConfirm;

  /// Package deleted snackbar
  ///
  /// In tr, this message translates to:
  /// **'Paket silindi'**
  String get packageDeleted;

  /// Delete failed snackbar
  ///
  /// In tr, this message translates to:
  /// **'Silinemedi: {error}'**
  String deleteFailed(String error);

  /// Special/custom badge label
  ///
  /// In tr, this message translates to:
  /// **'Özel'**
  String get special;

  /// Edit action
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// Deactivate action
  ///
  /// In tr, this message translates to:
  /// **'Pasife Al'**
  String get deactivate;

  /// Activate action
  ///
  /// In tr, this message translates to:
  /// **'Aktive Et'**
  String get activate;

  /// Enter valid number validation
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir sayı girin'**
  String get enterValidNumber;

  /// Select member dropdown hint
  ///
  /// In tr, this message translates to:
  /// **'Üye seç'**
  String get selectMemberHint;

  /// Select member validation message
  ///
  /// In tr, this message translates to:
  /// **'Üye seçin'**
  String get selectMemberRequired;

  /// Delete program menu item
  ///
  /// In tr, this message translates to:
  /// **'Programı Sil'**
  String get deleteProgram;

  /// Delete program confirmation
  ///
  /// In tr, this message translates to:
  /// **'Bu programı kalıcı olarak silmek istiyor musunuz?'**
  String get deleteProgramConfirm;

  /// OK button
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// Rest day label (short)
  ///
  /// In tr, this message translates to:
  /// **'Dinlenme'**
  String get restDay;

  /// Rest day toggle label
  ///
  /// In tr, this message translates to:
  /// **'Dinlenme Günü'**
  String get restDayLabel;

  /// Rest day full label with emoji
  ///
  /// In tr, this message translates to:
  /// **'Dinlenme Günü 🛌'**
  String get restDayFull;

  /// No exercises added yet
  ///
  /// In tr, this message translates to:
  /// **'Henüz egzersiz eklenmedi'**
  String get noExercisesYet;

  /// My workout program screen title
  ///
  /// In tr, this message translates to:
  /// **'Antrenman Programım'**
  String get myWorkoutProgram;

  /// Program name field label
  ///
  /// In tr, this message translates to:
  /// **'Program Adı'**
  String get programName;

  /// Program updated snackbar
  ///
  /// In tr, this message translates to:
  /// **'Program güncellendi'**
  String get programUpdated;

  /// Program created snackbar
  ///
  /// In tr, this message translates to:
  /// **'Program oluşturuldu'**
  String get programCreated;

  /// Week count label
  ///
  /// In tr, this message translates to:
  /// **'Hafta Sayısı:'**
  String get weekCountLabel;

  /// Add workout to day button
  ///
  /// In tr, this message translates to:
  /// **'Antrenman Ekle'**
  String get addWorkout;

  /// Add exercise button
  ///
  /// In tr, this message translates to:
  /// **'Egzersiz Ekle'**
  String get addExercise;

  /// Exercise name field
  ///
  /// In tr, this message translates to:
  /// **'Egzersiz Adı'**
  String get exerciseName;

  /// Sets field label
  ///
  /// In tr, this message translates to:
  /// **'Set'**
  String get sets;

  /// Reps field label
  ///
  /// In tr, this message translates to:
  /// **'Tekrar'**
  String get reps;

  /// Weight in kg field
  ///
  /// In tr, this message translates to:
  /// **'Ağırlık (kg)'**
  String get weightKg;

  /// Rest seconds field
  ///
  /// In tr, this message translates to:
  /// **'Dinlenme (sn)'**
  String get restSeconds;

  /// Note field label
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get noteLabel;

  /// Please select a member snackbar
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir üye seçin'**
  String get selectMemberSnack;

  /// Members load failed message
  ///
  /// In tr, this message translates to:
  /// **'Üyeler yüklenemedi'**
  String get membersLoadFailed;

  /// Edit program screen title
  ///
  /// In tr, this message translates to:
  /// **'Programı Düzenle'**
  String get editProgram;

  /// Sending invitation loading message
  ///
  /// In tr, this message translates to:
  /// **'Davet gönderiliyor...'**
  String get sendingInvitation;

  /// Member info section title
  ///
  /// In tr, this message translates to:
  /// **'Üye Bilgileri'**
  String get memberInfo;

  /// Member email search instructions
  ///
  /// In tr, this message translates to:
  /// **'Üyenin e-posta adresiyle arama yapın. Üye önce uygulamaya kayıt olmalı.'**
  String get memberEmailInstructions;

  /// Goal optional field label
  ///
  /// In tr, this message translates to:
  /// **'Hedef (İsteğe bağlı)'**
  String get goalOptional;

  /// Alternative goal hint text
  ///
  /// In tr, this message translates to:
  /// **'Kilo verme, kas kazanma...'**
  String get goalHintAlt;

  /// Notes field hint text
  ///
  /// In tr, this message translates to:
  /// **'Özel durumlar, sağlık notları...'**
  String get notesHint;

  /// Send invitation button
  ///
  /// In tr, this message translates to:
  /// **'Davet Gönder'**
  String get sendInvitation;

  /// Member made active snackbar
  ///
  /// In tr, this message translates to:
  /// **'{name} aktif yapıldı'**
  String memberMadeActive(String name);

  /// Member made passive snackbar
  ///
  /// In tr, this message translates to:
  /// **'{name} pasif yapıldı'**
  String memberMadePassive(String name);

  /// Member delete confirmation content
  ///
  /// In tr, this message translates to:
  /// **'{name} kalıcı olarak silinecek. Bu işlem geri alınamaz.'**
  String memberDeleteConfirm(String name);

  /// No assigned programs subtitle
  ///
  /// In tr, this message translates to:
  /// **'PT\'niz size bir program atadığında burada görünür'**
  String get noAssignedPrograms;

  /// Week label used in tab/header
  ///
  /// In tr, this message translates to:
  /// **'Hafta'**
  String get weekLabel;

  /// Program not found placeholder
  ///
  /// In tr, this message translates to:
  /// **'Program bulunamadı'**
  String get programNotFound;

  /// Help guide screen title
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Kılavuzu'**
  String get helpGuideTitle;

  /// PT request dialog title
  ///
  /// In tr, this message translates to:
  /// **'PT\'ye İstek Gönder'**
  String get ptRequestTitle;

  /// PT request dialog content
  ///
  /// In tr, this message translates to:
  /// **'{ptName} adlı eğitmene katılım isteği göndermek istiyor musunuz?\n\nEğitmen isteği onayladıktan sonra bağlantı kurulacak.'**
  String ptRequestContent(String ptName);

  /// Request sent to PT snackbar
  ///
  /// In tr, this message translates to:
  /// **'{ptName} adlı eğitmene istek gönderildi'**
  String requestSentTo(String ptName);

  /// Find PT search hint
  ///
  /// In tr, this message translates to:
  /// **'İsim veya e-posta ile ara'**
  String get searchByNameOrEmail;

  /// Find PT empty search placeholder
  ///
  /// In tr, this message translates to:
  /// **'PT aramak için isim veya\ne-posta girin'**
  String get searchHintFull;

  /// No search results for query
  ///
  /// In tr, this message translates to:
  /// **'\"{query}\" için sonuç bulunamadı'**
  String noResultFor(String query);

  /// PT connected snackbar
  ///
  /// In tr, this message translates to:
  /// **'{ptName} ile bağlantı kuruldu'**
  String ptConnected(String ptName);

  /// Invitation rejected snackbar
  ///
  /// In tr, this message translates to:
  /// **'Davet reddedildi'**
  String get invitationRejected;

  /// Invitation date label
  ///
  /// In tr, this message translates to:
  /// **'Davet: {date}'**
  String invitationDate(String date);

  /// No invitations yet subtitle
  ///
  /// In tr, this message translates to:
  /// **'PT\'niz sizi davet ettiğinde burada görünür'**
  String get noInvitationsYetSub;

  /// Member delete error snackbar
  ///
  /// In tr, this message translates to:
  /// **'Silme hatası: {error}'**
  String memberDeleteError(String error);

  /// Remaining sessions count in member header
  ///
  /// In tr, this message translates to:
  /// **'{count} seans kaldı'**
  String sessionsLeft(int count);

  /// No programs for member
  ///
  /// In tr, this message translates to:
  /// **'Henüz program yok'**
  String get noMemberPrograms;

  /// No sessions for member
  ///
  /// In tr, this message translates to:
  /// **'Henüz seans yok'**
  String get noMemberSessions;

  /// Personal event option title
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Etkinlik'**
  String get personalEvent;

  /// Delete event dialog title
  ///
  /// In tr, this message translates to:
  /// **'Etkinliği Sil'**
  String get deleteEventTitle;

  /// Delete event dialog confirm message
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" etkinliğini silmek istiyor musunuz?'**
  String deleteEventConfirm(String title);

  /// Anonymous member name fallback
  ///
  /// In tr, this message translates to:
  /// **'İsimsiz Üye'**
  String get anonymousMember;

  /// Sessions count label
  ///
  /// In tr, this message translates to:
  /// **'{count} seans'**
  String sessionsCount(int count);

  /// Events count label
  ///
  /// In tr, this message translates to:
  /// **'{count} etkinlik'**
  String eventsCount(int count);

  /// No programs yet subtitle
  ///
  /// In tr, this message translates to:
  /// **'Üyeleriniz için antrenman programı oluşturun'**
  String get noProgramsYetSub;

  /// Week program label
  ///
  /// In tr, this message translates to:
  /// **'{count} Hafta Programı'**
  String weekProgramLabel(int count);

  /// Exercises count label
  ///
  /// In tr, this message translates to:
  /// **'{count} egzersiz'**
  String exercisesCount(int count);

  /// Completed payments count chip label
  ///
  /// In tr, this message translates to:
  /// **'{count} Ödeme'**
  String completedPaymentsCount(int count);

  /// Pending payments count chip label
  ///
  /// In tr, this message translates to:
  /// **'{count} Bekleyen'**
  String pendingPaymentsCount(int count);

  /// Pending approval section header with count
  ///
  /// In tr, this message translates to:
  /// **'Onay Bekleyen ({count})'**
  String pendingApprovalCount(int count);

  /// No payments yet subtitle
  ///
  /// In tr, this message translates to:
  /// **'Üyeleriniz paket satın aldığında burada görünür'**
  String get noPaymentsYetSub;

  /// Transaction history section header
  ///
  /// In tr, this message translates to:
  /// **'İşlem Geçmişi'**
  String get transactionHistory;

  /// Sessions loaded to member snackbar
  ///
  /// In tr, this message translates to:
  /// **'{count} seans üyeye yüklendi'**
  String sessionsLoadedToMember(int count);

  /// Payment request rejected snackbar
  ///
  /// In tr, this message translates to:
  /// **'Ödeme talebi reddedildi'**
  String get paymentRequestRejected;

  /// Status label in session detail
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get statusLabel;

  /// Cancel session button label
  ///
  /// In tr, this message translates to:
  /// **'İptal Et'**
  String get cancelSession;

  /// Mark as completed button label
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı Olarak İşaretle'**
  String get markAsCompleted;

  /// Duration in minutes value label
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dakika'**
  String durationMinutesValue(int minutes);

  /// Request rejected snackbar
  ///
  /// In tr, this message translates to:
  /// **'İstek reddedildi'**
  String get requestRejected;

  /// Member added snackbar message
  ///
  /// In tr, this message translates to:
  /// **'{name} üye olarak eklendi'**
  String memberAddedSnack(String name);

  /// Rest day message in workout detail
  ///
  /// In tr, this message translates to:
  /// **'Bugün dinlenme günü 🛌 İyi dinlenmeler!'**
  String get restDayMessage;

  /// Member activated snackbar
  ///
  /// In tr, this message translates to:
  /// **'{name} aktif hale getirildi'**
  String memberActivatedSnack(String name);

  /// App subtitle shown on splash screen
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Antrenman Uygulaması'**
  String get appSubtitle;

  /// Weight chip label (no unit)
  ///
  /// In tr, this message translates to:
  /// **'Kilo'**
  String get weightShort;

  /// Waist chip label (no unit)
  ///
  /// In tr, this message translates to:
  /// **'Bel'**
  String get waistShort;

  /// Chest chip label (no unit)
  ///
  /// In tr, this message translates to:
  /// **'Göğüs'**
  String get chestShort;

  /// Hips chip label (no unit)
  ///
  /// In tr, this message translates to:
  /// **'Kalça'**
  String get hipsShort;

  /// Purchase confirmation dialog content
  ///
  /// In tr, this message translates to:
  /// **'{name} paketini {price} karşılığında satın almak istiyor musunuz?\n\n{count} seans hakkı PT onayından sonra hesabınıza yüklenecektir.'**
  String purchaseDialogContent(String name, String price, int count);

  /// Help screen welcome title
  ///
  /// In tr, this message translates to:
  /// **'BookMyPT\'e Hoş Geldiniz!'**
  String get helpWelcomeTitle;

  /// Help screen member intro body
  ///
  /// In tr, this message translates to:
  /// **'Bu uygulama sayesinde eğitmeninizle kolayca randevu alabilir, ilerlemenizi takip edebilir ve seans paketlerinizi yönetebilirsiniz.'**
  String get helpMemberIntroBody;

  /// Help screen PT intro body
  ///
  /// In tr, this message translates to:
  /// **'Bu uygulama sayesinde üyelerinizin randevularını kolayca yönetebilir, seans paketleri oluşturabilir ve kazançlarınızı takip edebilirsiniz.'**
  String get helpPtIntroBody;

  /// Help home section title
  ///
  /// In tr, this message translates to:
  /// **'Ana Ekran'**
  String get helpHomeTitle;

  /// Help home item 1 title (member)
  ///
  /// In tr, this message translates to:
  /// **'Eğitmen Bilgileri'**
  String get helpHomeItem1Title;

  /// Help home item 1 body (member)
  ///
  /// In tr, this message translates to:
  /// **'Atanmış PT\'niz, kalan seans hakkınız ve yaklaşan randevularınız ana ekranda bir bakışta görünür.'**
  String get helpHomeItem1Body;

  /// Help home item 2 title (member)
  ///
  /// In tr, this message translates to:
  /// **'PT Atanmamışsa'**
  String get helpHomeItem2Title;

  /// Help home item 2 body (member)
  ///
  /// In tr, this message translates to:
  /// **'\"PT Bul\" özelliği üzerinden e-posta adresiyle eğitmeninizi sisteme ekleyebilirsiniz. PT sizi sisteme aldıktan sonra randevu ve paket işlemleri aktif olur.'**
  String get helpHomeItem2Body;

  /// Help home item 3 title (member)
  ///
  /// In tr, this message translates to:
  /// **'Üyeliği Bırak'**
  String get helpHomeItem3Title;

  /// Help home item 3 body (member)
  ///
  /// In tr, this message translates to:
  /// **'PT kartındaki \"Üyeliği Bırak\" butonuyla eğitmeninizle bağlantınızı kesebilirsiniz. Kalan seans haklarınız bu işlemden etkilenmez.'**
  String get helpHomeItem3Body;

  /// Help calendar section title (member)
  ///
  /// In tr, this message translates to:
  /// **'Randevularım'**
  String get helpCalendarTitle;

  /// Help calendar item 1 title
  ///
  /// In tr, this message translates to:
  /// **'Randevu Talebi Oluşturma'**
  String get helpCalendarItem1Title;

  /// Help calendar item 1 body
  ///
  /// In tr, this message translates to:
  /// **'Sağ üstteki + butonuna basın, tarih ve saati seçin. Paketinizde seans süresi tanımlıysa otomatik belirlenir. Talebiniz PT onayına gönderilir.'**
  String get helpCalendarItem1Body;

  /// Help calendar item 2 title
  ///
  /// In tr, this message translates to:
  /// **'Takvim Sekmesi'**
  String get helpCalendarItem2Title;

  /// Help calendar item 2 body
  ///
  /// In tr, this message translates to:
  /// **'Günlük bazda tüm randevularınızı görürsünüz. Mavi nokta kendi randevularınızı, gri nokta PT\'nin meşgul olduğu saatleri gösterir. Bekleyen taleplerinize tıklayarak tarih veya saati değiştirebilirsiniz.'**
  String get helpCalendarItem2Body;

  /// Help calendar item 3 title
  ///
  /// In tr, this message translates to:
  /// **'Geçmişim Sekmesi'**
  String get helpCalendarItem3Title;

  /// Help calendar item 3 body
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan seanslarınızın sayısı ve toplam süresini burada görürsünüz. Yaklaşan onaylı randevularınız da bu sekmede listelenir.'**
  String get helpCalendarItem3Body;

  /// Help calendar item 4 title
  ///
  /// In tr, this message translates to:
  /// **'Randevu Durumları'**
  String get helpCalendarItem4Title;

  /// Help calendar item 4 body
  ///
  /// In tr, this message translates to:
  /// **'• Bekliyor: Talep oluşturuldu, PT onayı bekleniyor.\n• Onaylandı: PT kabul etti, seans gerçekleşecek.\n• Tamamlandı: Seans gerçekleşti.\n• İptal: Seans iptal edildi.'**
  String get helpCalendarItem4Body;

  /// Help my-calendar section title (member)
  ///
  /// In tr, this message translates to:
  /// **'Takvimim'**
  String get helpMyCalendarTitle;

  /// Help my-calendar item 1 title
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Etkinlik Ekleme'**
  String get helpMyCalendarItem1Title;

  /// Help my-calendar item 1 body
  ///
  /// In tr, this message translates to:
  /// **'Sağ üstteki + butonuyla kişisel etkinlikler ekleyebilirsiniz (antrenman, toplantı, tatil vb.). Bu etkinlikler yalnızca sizin takviminizde görünür.'**
  String get helpMyCalendarItem1Body;

  /// Help my-calendar item 2 title
  ///
  /// In tr, this message translates to:
  /// **'PT\'nin Müsaitliği'**
  String get helpMyCalendarItem2Title;

  /// Help my-calendar item 2 body
  ///
  /// In tr, this message translates to:
  /// **'PT\'nizin başka üyelerle olan randevuları ve kişisel etkinlikleri gri renkte görünür. Böylece randevu talebinde bulunmadan önce müsaitliği kontrol edebilirsiniz.'**
  String get helpMyCalendarItem2Body;

  /// Help my-calendar item 3 title
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik Düzenleme'**
  String get helpMyCalendarItem3Title;

  /// Help my-calendar item 3 body
  ///
  /// In tr, this message translates to:
  /// **'Eklediğiniz kişisel etkinliklere tıklayarak tarih, saat, süre ve notlarını düzenleyebilir ya da silebilirsiniz.'**
  String get helpMyCalendarItem3Body;

  /// Help packages section title (member)
  ///
  /// In tr, this message translates to:
  /// **'Paketlerim'**
  String get helpPackagesTitle;

  /// Help packages item 1 title
  ///
  /// In tr, this message translates to:
  /// **'Paket Satın Alma'**
  String get helpPackagesItem1Title;

  /// Help packages item 1 body
  ///
  /// In tr, this message translates to:
  /// **'PT\'nizin sunduğu seans paketlerini bu ekranda görürsünüz. \"Satın Al\" butonuna bastığınızda ödeme talebi oluşur; PT onayladıktan sonra seans hakkınız hesabınıza eklenir.'**
  String get helpPackagesItem1Body;

  /// Help packages item 2 title
  ///
  /// In tr, this message translates to:
  /// **'Üyeye Özel Paketler'**
  String get helpPackagesItem2Title;

  /// Help packages item 2 body
  ///
  /// In tr, this message translates to:
  /// **'PT\'niz sizin için özel fiyatlı veya süreli paket oluşturmuş olabilir. Bu paketleri yalnızca siz görebilirsiniz.'**
  String get helpPackagesItem2Body;

  /// Help packages item 3 title
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Geçmişi'**
  String get helpPackagesItem3Title;

  /// Help packages item 3 body
  ///
  /// In tr, this message translates to:
  /// **'Tüm ödeme talepleriniz ve durumları (Bekliyor / Tamamlandı) ekranın üst kısmında listelenir.'**
  String get helpPackagesItem3Body;

  /// Help progress section title (member)
  ///
  /// In tr, this message translates to:
  /// **'İlerleme'**
  String get helpProgressTitle;

  /// Help progress item 1 title
  ///
  /// In tr, this message translates to:
  /// **'Ölçüm Girişi'**
  String get helpProgressItem1Title;

  /// Help progress item 1 body
  ///
  /// In tr, this message translates to:
  /// **'Kilo, boy ve vücut ölçülerinizi kaydedebilirsiniz. Fotoğraf ekleyerek görsel ilerlemenizi de takip edebilirsiniz.'**
  String get helpProgressItem1Body;

  /// Help progress item 2 title
  ///
  /// In tr, this message translates to:
  /// **'Geçmişe Dönük Giriş'**
  String get helpProgressItem2Title;

  /// Help progress item 2 body
  ///
  /// In tr, this message translates to:
  /// **'Girişi unuttuğunuz günler için tarih seçerek geçmişe dönük kayıt yapabilirsiniz.'**
  String get helpProgressItem2Body;

  /// Help progress item 3 title
  ///
  /// In tr, this message translates to:
  /// **'Grafik Takibi'**
  String get helpProgressItem3Title;

  /// Help progress item 3 body
  ///
  /// In tr, this message translates to:
  /// **'Kaydettiğiniz ölçümler grafik olarak gösterilir. Zaman içindeki değişiminizi kolayca izleyebilirsiniz.'**
  String get helpProgressItem3Body;

  /// Help messages section title
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get helpMessagesTitle;

  /// Help messages item 1 title (member)
  ///
  /// In tr, this message translates to:
  /// **'PT ile İletişim'**
  String get helpMemberMessagesItem1Title;

  /// Help messages item 1 body (member)
  ///
  /// In tr, this message translates to:
  /// **'PT\'nizle doğrudan mesajlaşabilirsiniz. Seans değişiklikleri, sorular veya antrenman notları için bu ekranı kullanın.'**
  String get helpMemberMessagesItem1Body;

  /// Help home item 1 title (PT)
  ///
  /// In tr, this message translates to:
  /// **'Günlük Özet'**
  String get helpPtHomeItem1Title;

  /// Help home item 1 body (PT)
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü randevularınız, bekleyen talepler ve son üye hareketleri ana ekranda listelenir.'**
  String get helpPtHomeItem1Body;

  /// Help home item 2 title (PT)
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen Talepler'**
  String get helpPtHomeItem2Title;

  /// Help home item 2 body (PT)
  ///
  /// In tr, this message translates to:
  /// **'Üyelerinizin randevu taleplerini buradan hızlıca onaylayabilir veya reddedebilirsiniz. Onay verdiğinizde üyeye bildirim gider.'**
  String get helpPtHomeItem2Body;

  /// Help home item 3 title (PT)
  ///
  /// In tr, this message translates to:
  /// **'Aktivasyon İstekleri'**
  String get helpPtHomeItem3Title;

  /// Help home item 3 body (PT)
  ///
  /// In tr, this message translates to:
  /// **'Pasif üyeler aktivasyon isteği gönderebilir. Bu istekleri ana ekrandan yönetebilirsiniz.'**
  String get helpPtHomeItem3Body;

  /// Help calendar section title (PT)
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get helpPtCalendarTitle;

  /// Help PT calendar item 1 title
  ///
  /// In tr, this message translates to:
  /// **'Randevu Yönetimi'**
  String get helpPtCalendarItem1Title;

  /// Help PT calendar item 1 body
  ///
  /// In tr, this message translates to:
  /// **'Tüm üyelerinizin seansları takvimde renkli noktalarla görünür. Bir güne tıklayarak o günkü detaylı listeye geçebilirsiniz.'**
  String get helpPtCalendarItem1Body;

  /// Help PT calendar item 2 title
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Etkinlik'**
  String get helpPtCalendarItem2Title;

  /// Help PT calendar item 2 body
  ///
  /// In tr, this message translates to:
  /// **'Sağ üstteki + butonu ile tatil, toplantı gibi kişisel etkinlikler ekleyebilirsiniz. Bu saatler üyelerin randevu takviminde \"meşgul\" olarak görünür.'**
  String get helpPtCalendarItem2Body;

  /// Help PT calendar item 3 title
  ///
  /// In tr, this message translates to:
  /// **'Seans Detayı'**
  String get helpPtCalendarItem3Title;

  /// Help PT calendar item 3 body
  ///
  /// In tr, this message translates to:
  /// **'Listedeki bir seansa tıklayarak detay ekranını açabilir, durumu güncelleyebilir (onayla / iptal / tamamla) ve notlar ekleyebilirsiniz.'**
  String get helpPtCalendarItem3Body;

  /// Help PT members section title
  ///
  /// In tr, this message translates to:
  /// **'Üyeler'**
  String get helpPtMembersTitle;

  /// Help PT members item 1 title
  ///
  /// In tr, this message translates to:
  /// **'Üye Ekleme'**
  String get helpPtMembersItem1Title;

  /// Help PT members item 1 body
  ///
  /// In tr, this message translates to:
  /// **'Yeni üye eklemek için + butonuna basın ve üyenin bilgilerini girin. Sisteme eklenen üye size bağlanır ve randevu alabilir.'**
  String get helpPtMembersItem1Body;

  /// Help PT members item 2 title
  ///
  /// In tr, this message translates to:
  /// **'Üye Yönetimi'**
  String get helpPtMembersItem2Title;

  /// Help PT members item 2 body
  ///
  /// In tr, this message translates to:
  /// **'Üye kartına tıklayarak profil detayını görüntüleyebilir, kişisel hedef ve notlar ekleyebilir, kalan seans haklarını takip edebilirsiniz.'**
  String get helpPtMembersItem2Body;

  /// Help PT members item 3 title
  ///
  /// In tr, this message translates to:
  /// **'Aktif / Pasif Durumu'**
  String get helpPtMembersItem3Title;

  /// Help PT members item 3 body
  ///
  /// In tr, this message translates to:
  /// **'Üyeyi pasife aldığınızda o üye yeni randevu talebi oluşturamaz. Aktivasyon isteği gönderirse siz onaylarsınız.'**
  String get helpPtMembersItem3Body;

  /// Help PT packages section title
  ///
  /// In tr, this message translates to:
  /// **'Paket Yönetimi'**
  String get helpPtPackagesTitle;

  /// Help PT packages item 1 title
  ///
  /// In tr, this message translates to:
  /// **'Paket Oluşturma'**
  String get helpPtPackagesItem1Title;

  /// Help PT packages item 1 body
  ///
  /// In tr, this message translates to:
  /// **'Seans sayısı, süresi ve fiyatını belirleyerek paket oluşturabilirsiniz. Paketler tüm aktif üyelerinize görünür.'**
  String get helpPtPackagesItem1Body;

  /// Help PT packages item 2 title
  ///
  /// In tr, this message translates to:
  /// **'Üyeye Özel Paket'**
  String get helpPtPackagesItem2Title;

  /// Help PT packages item 2 body
  ///
  /// In tr, this message translates to:
  /// **'\"Üyeye özel\" seçeneğiyle belirli bir üye için özel fiyatlı paket tanımlayabilirsiniz. Bu paket yalnızca o üyenin Paketlerim ekranında görünür.'**
  String get helpPtPackagesItem2Body;

  /// Help PT packages item 3 title
  ///
  /// In tr, this message translates to:
  /// **'Seans Süresi'**
  String get helpPtPackagesItem3Title;

  /// Help PT packages item 3 body
  ///
  /// In tr, this message translates to:
  /// **'Pakette seans süresi belirtirseniz, o üye randevu alırken süre otomatik olarak belirlenir ve üye manuel seçim yapamaz.'**
  String get helpPtPackagesItem3Body;

  /// Help PT earnings section title
  ///
  /// In tr, this message translates to:
  /// **'Kazançlar & Ödemeler'**
  String get helpPtEarningsTitle;

  /// Help PT earnings item 1 title
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Onaylama'**
  String get helpPtEarningsItem1Title;

  /// Help PT earnings item 1 body
  ///
  /// In tr, this message translates to:
  /// **'Üye paket satın aldığında ödeme talebi oluşur. Siz onayladığınızda üyenin seans hakkı otomatik olarak güncellenir ve üyeye bildirim gider.'**
  String get helpPtEarningsItem1Body;

  /// Help PT earnings item 2 title
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Reddetme'**
  String get helpPtEarningsItem2Title;

  /// Help PT earnings item 2 body
  ///
  /// In tr, this message translates to:
  /// **'Ödemenin gerçekleşmediği durumlarda talebi reddedebilirsiniz. Seans hakkı eklenmez.'**
  String get helpPtEarningsItem2Body;

  /// Help PT earnings item 3 title
  ///
  /// In tr, this message translates to:
  /// **'Kazanç Özeti'**
  String get helpPtEarningsItem3Title;

  /// Help PT earnings item 3 body
  ///
  /// In tr, this message translates to:
  /// **'Aylık ve toplam kazanç özeti ekranın üst kısmında görünür.'**
  String get helpPtEarningsItem3Body;

  /// Help PT messages item 1 title
  ///
  /// In tr, this message translates to:
  /// **'Üye İletişimi'**
  String get helpPtMessagesItem1Title;

  /// Help PT messages item 1 body
  ///
  /// In tr, this message translates to:
  /// **'Tüm üyelerinizle ayrı ayrı mesajlaşabilirsiniz. Antrenman notları, diyet önerileri veya seans değişiklikleri için kullanın.'**
  String get helpPtMessagesItem1Body;

  /// Help tip box body text
  ///
  /// In tr, this message translates to:
  /// **'Sorun yaşarsanız uygulamayı kapatıp yeniden açmayı deneyin. Bildirim almak için Profil → Bildirimler bölümünden bildirim izinlerini kontrol edin.'**
  String get helpTipBody;

  /// Google sign-in button label
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get signInWithGoogle;

  /// No pending requests empty state message
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen istek yok'**
  String get noPendingRequests;

  /// No pending requests empty state subtitle
  ///
  /// In tr, this message translates to:
  /// **'Üyeler size katılmak için istek gönderdiğinde burada görünür'**
  String get noPendingRequestsSub;

  /// Activation request label
  ///
  /// In tr, this message translates to:
  /// **'Aktivasyon isteği'**
  String get activationRequest;

  /// Join request label
  ///
  /// In tr, this message translates to:
  /// **'Katılım isteği'**
  String get joinRequest;

  /// Program name field hint text
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Programı'**
  String get programNameHint;

  /// Program description field hint text
  ///
  /// In tr, this message translates to:
  /// **'Program hakkında kısa bilgi'**
  String get programDescriptionHint;

  /// Color scheme section header in appearance sheet
  ///
  /// In tr, this message translates to:
  /// **'Renk Şeması'**
  String get colorSchemeSection;

  /// Classic color scheme name
  ///
  /// In tr, this message translates to:
  /// **'Klasik'**
  String get colorSchemeClassic;

  /// Classic color scheme subtitle
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan renk teması'**
  String get colorSchemeClassicSub;

  /// Sport color scheme name
  ///
  /// In tr, this message translates to:
  /// **'Spor'**
  String get colorSchemeSport;

  /// Sport color scheme subtitle
  ///
  /// In tr, this message translates to:
  /// **'Canlı ve enerjik renkler'**
  String get colorSchemeSportSub;

  /// Delete message for me only
  ///
  /// In tr, this message translates to:
  /// **'Benden Sil'**
  String get deleteForMe;

  /// Delete message for everyone
  ///
  /// In tr, this message translates to:
  /// **'Herkesten Sil'**
  String get deleteForEveryone;

  /// Deleted message placeholder text
  ///
  /// In tr, this message translates to:
  /// **'Bu mesaj silindi'**
  String get messageDeleted;

  /// Groups tab/nav label
  ///
  /// In tr, this message translates to:
  /// **'Gruplar'**
  String get groups;

  /// Group singular label
  ///
  /// In tr, this message translates to:
  /// **'Grup'**
  String get group;

  /// No groups yet empty state
  ///
  /// In tr, this message translates to:
  /// **'Henüz grup yok'**
  String get noGroupsYet;

  /// Create group hint subtitle
  ///
  /// In tr, this message translates to:
  /// **'Grup oluşturmak için + butonuna tıklayın'**
  String get createGroupHint;

  /// Create group button / screen title
  ///
  /// In tr, this message translates to:
  /// **'Grup Oluştur'**
  String get createGroup;

  /// Edit group screen title
  ///
  /// In tr, this message translates to:
  /// **'Grubu Düzenle'**
  String get editGroup;

  /// Delete group menu item
  ///
  /// In tr, this message translates to:
  /// **'Grubu Sil'**
  String get deleteGroup;

  /// Delete group confirmation message
  ///
  /// In tr, this message translates to:
  /// **'Bu grubu silmek istiyor musunuz? Geçmiş seans kayıtları korunur.'**
  String get deleteGroupConfirm;

  /// Group name field label
  ///
  /// In tr, this message translates to:
  /// **'Grup Adı'**
  String get groupName;

  /// Group name field hint
  ///
  /// In tr, this message translates to:
  /// **'Sabah Grubu, Kilo Verme Grubu...'**
  String get groupNameHint;

  /// Group description field label
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get groupDescription;

  /// Group description field hint
  ///
  /// In tr, this message translates to:
  /// **'Grup hakkında kısa bilgi'**
  String get groupDescriptionHint;

  /// Group color picker label
  ///
  /// In tr, this message translates to:
  /// **'Grup Rengi'**
  String get groupColor;

  /// Validation: group needs at least one member
  ///
  /// In tr, this message translates to:
  /// **'En az bir üye seçmelisiniz'**
  String get groupNeedMembers;

  /// Select members section label
  ///
  /// In tr, this message translates to:
  /// **'Üye Seç'**
  String get selectMembers;

  /// Selected count suffix (e.g. '3 seçili')
  ///
  /// In tr, this message translates to:
  /// **'seçili'**
  String get selected;

  /// No active members to select
  ///
  /// In tr, this message translates to:
  /// **'Aktif üye bulunamadı'**
  String get noActiveMembers;

  /// Members tab label
  ///
  /// In tr, this message translates to:
  /// **'Üyeler'**
  String get members;

  /// No members in group empty state
  ///
  /// In tr, this message translates to:
  /// **'Grupta henüz üye yok'**
  String get noMembersInGroup;

  /// Packages tab label
  ///
  /// In tr, this message translates to:
  /// **'Paketler'**
  String get packages;

  /// Per member price suffix
  ///
  /// In tr, this message translates to:
  /// **'üye başına'**
  String get perMember;

  /// Inactive status chip label
  ///
  /// In tr, this message translates to:
  /// **'Pasif'**
  String get inactive;

  /// Required field validation message
  ///
  /// In tr, this message translates to:
  /// **'Zorunlu alan'**
  String get required;

  /// Price field label
  ///
  /// In tr, this message translates to:
  /// **'Fiyat'**
  String get price;

  /// Session count field label
  ///
  /// In tr, this message translates to:
  /// **'Seans Sayısı'**
  String get sessionCount;

  /// New session screen title
  ///
  /// In tr, this message translates to:
  /// **'Yeni Seans'**
  String get newSession;

  /// Session detail screen title
  ///
  /// In tr, this message translates to:
  /// **'Seans Detayı'**
  String get sessionDetail;

  /// Date and time field label
  ///
  /// In tr, this message translates to:
  /// **'Tarih & Saat'**
  String get dateTime;

  /// Attendance section label
  ///
  /// In tr, this message translates to:
  /// **'Katılım'**
  String get attendance;

  /// Attended count suffix (e.g. '3/5 katıldı')
  ///
  /// In tr, this message translates to:
  /// **'katıldı'**
  String get attended;

  /// Scheduled session status chip
  ///
  /// In tr, this message translates to:
  /// **'Planlandı'**
  String get scheduled;

  /// Completed status chip label
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get completed;

  /// Cancelled status chip label
  ///
  /// In tr, this message translates to:
  /// **'İptal Edildi'**
  String get cancelled;

  /// Session completed chip label
  ///
  /// In tr, this message translates to:
  /// **'Seans Tamamlandı'**
  String get sessionCompleted;

  /// Cancel session confirmation message
  ///
  /// In tr, this message translates to:
  /// **'Bu seansı iptal etmek istiyor musunuz?'**
  String get cancelSessionConfirm;

  /// No group sessions yet empty state
  ///
  /// In tr, this message translates to:
  /// **'Henüz seans yok'**
  String get noSessionsYet;

  /// Notes optional hint text
  ///
  /// In tr, this message translates to:
  /// **'Notlar (İsteğe bağlı)'**
  String get optionalNotes;

  /// Participants count suffix
  ///
  /// In tr, this message translates to:
  /// **'katılımcı'**
  String get participants;

  /// Open chat button in group detail
  ///
  /// In tr, this message translates to:
  /// **'Sohbeti Aç'**
  String get openChat;

  /// Individual packages tab label
  ///
  /// In tr, this message translates to:
  /// **'Bireysel'**
  String get individual;

  /// Group packages tab label
  ///
  /// In tr, this message translates to:
  /// **'Grup Paketleri'**
  String get groupPackages;

  /// Member not in any group empty state
  ///
  /// In tr, this message translates to:
  /// **'Herhangi bir gruba üye değilsiniz'**
  String get notInAnyGroup;

  /// No group packages available empty state
  ///
  /// In tr, this message translates to:
  /// **'Henüz grup paketi bulunmuyor'**
  String get noGroupPackagesYet;

  /// Already purchased button label (disabled)
  ///
  /// In tr, this message translates to:
  /// **'Satın Alındı'**
  String get alreadyPurchased;

  /// Group package purchase confirmation dialog content
  ///
  /// In tr, this message translates to:
  /// **'{name} paketini {groupName} grubu için {price} karşılığında satın almak istiyor musunuz?\n\n{count} seans hakkı PT onayından sonra hesabınıza yüklenecektir.'**
  String groupPurchaseConfirm(
      String name, String groupName, String price, int count);

  /// Button to send a cancellation request for a confirmed session
  ///
  /// In tr, this message translates to:
  /// **'İptal Talebi Gönder'**
  String get sendCancellationRequest;

  /// Label shown when the current user already sent a cancellation request
  ///
  /// In tr, this message translates to:
  /// **'İptal Talebiniz Gönderildi'**
  String get cancellationRequestSent;

  /// Label shown to PT when member sent a cancellation request
  ///
  /// In tr, this message translates to:
  /// **'Üye İptal Talep Etti'**
  String get memberRequestedCancellation;

  /// Label shown to member when PT sent a cancellation request
  ///
  /// In tr, this message translates to:
  /// **'Eğitmen İptal Talep Etti'**
  String get ptRequestedCancellation;

  /// Accept a cancellation request button
  ///
  /// In tr, this message translates to:
  /// **'İptali Onayla'**
  String get acceptCancellation;

  /// Reject a cancellation request button
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get rejectCancellation;

  /// Confirmation dialog for sending a cancellation request
  ///
  /// In tr, this message translates to:
  /// **'İptal talebiniz karşı tarafa iletilecek. Devam etmek istiyor musunuz?'**
  String get cancellationRequestConfirm;

  /// Tooltip shown when mark-as-completed is disabled for a future session
  ///
  /// In tr, this message translates to:
  /// **'Gelecekteki bir seans tamamlanamaz'**
  String get sessionInFutureWarning;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
