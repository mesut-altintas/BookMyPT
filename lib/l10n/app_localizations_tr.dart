// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'BookMyPT';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get confirm => 'Onayla';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get continueText => 'Devam Et';

  @override
  String get update => 'Güncelle';

  @override
  String get add => 'Ekle';

  @override
  String get send => 'Gönder';

  @override
  String get seeAll => 'Tümünü Gör';

  @override
  String get all => 'Tümü';

  @override
  String get active => 'Aktif';

  @override
  String get passive => 'Pasif';

  @override
  String get requests => 'İstekler';

  @override
  String error(String message) {
    return 'Hata: $message';
  }

  @override
  String get sessions => 'seans';

  @override
  String get minuteShort => 'dk';

  @override
  String helloName(String name) {
    return 'Merhaba, $name!';
  }

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get welcomeTitle => 'Hoş Geldiniz';

  @override
  String get signInSubtitle => 'Hesabınıza giriş yapın';

  @override
  String get email => 'E-posta';

  @override
  String get emailHint => 'ornek@email.com';

  @override
  String get password => 'Şifre';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get orDivider => 'veya';

  @override
  String get noAccount => 'Hesabınız yok mu? ';

  @override
  String get errorGoogleSignIn => 'Google ile giriş başarısız';

  @override
  String get errorUserNotFound => 'Bu e-posta kayıtlı değil';

  @override
  String get errorWrongPassword => 'Şifre hatalı';

  @override
  String get errorInvalidCredential => 'E-posta veya şifre hatalı';

  @override
  String get errorTooManyRequests => 'Çok fazla deneme. Lütfen bekleyin';

  @override
  String get errorInvalidEmail => 'Geçersiz e-posta adresi';

  @override
  String get errorNetworkFailed => 'İnternet bağlantısı hatası';

  @override
  String get errorUserDisabled => 'Bu hesap devre dışı bırakıldı';

  @override
  String get errorSignInFailed => 'Giriş başarısız. Lütfen tekrar deneyin';

  @override
  String get registerTitle => 'Kayıt Ol';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get enterInfoToContinue => 'Bilgilerinizi girerek devam edin';

  @override
  String get fullName => 'Ad Soyad';

  @override
  String get fullNameHint => 'Ali Yılmaz';

  @override
  String get passwordHint => 'En az 6 karakter';

  @override
  String get confirmPassword => 'Şifre Tekrar';

  @override
  String get confirmPasswordHint => 'Şifrenizi tekrar girin';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı? ';

  @override
  String get errorEmailInUse => 'Bu e-posta zaten kayıtlı';

  @override
  String get errorWeakPassword => 'Şifre çok zayıf';

  @override
  String get errorRegisterFailed => 'Kayıt başarısız. Lütfen tekrar deneyin';

  @override
  String get forgotPasswordTitle => 'Şifremi Unuttum';

  @override
  String get resetPassword => 'Şifre Sıfırlama';

  @override
  String get resetPasswordSubtitle =>
      'E-posta adresinize sıfırlama bağlantısı göndereceğiz';

  @override
  String get sendResetLink => 'Sıfırlama Bağlantısı Gönder';

  @override
  String get emailSent => 'E-posta Gönderildi';

  @override
  String emailSentMessage(String email) {
    return '$email adresine şifre sıfırlama bağlantısı gönderildi';
  }

  @override
  String get backToLogin => 'Giriş Sayfasına Dön';

  @override
  String get selectRole => 'Rolünüzü Seçin';

  @override
  String get howToUseApp => 'Uygulamayı nasıl kullanacaksınız?';

  @override
  String get rolePtTitle => 'Personal Trainer';

  @override
  String get rolePtSubtitle =>
      'Üyelerinizi yönetin, program oluşturun ve takvim tutun';

  @override
  String get roleMemberTitle => 'Üye';

  @override
  String get roleMemberSubtitle =>
      'PT\'nizin programını görün, randevu alın ve ilerlemenizi takip edin';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navCalendar => 'Takvim';

  @override
  String get navPrograms => 'Program';

  @override
  String get navProgress => 'İlerleme';

  @override
  String get navPackages => 'Paketler';

  @override
  String get navChat => 'Mesaj';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navMembers => 'Üyeler';

  @override
  String get navEarnings => 'Gelir';

  @override
  String get upcomingSessions => 'Yaklaşan Seanslar';

  @override
  String get noUpcomingSessions => 'Yaklaşan seans yok';

  @override
  String get recentMembers => 'Son Üyeler';

  @override
  String get noMembersYet => 'Henüz üye yok';

  @override
  String get addSession => 'Seans Ekle';

  @override
  String get totalMembers => 'Toplam Üye';

  @override
  String get thisWeek => 'Bu Hafta';

  @override
  String get goalNotSet => 'Hedef belirtilmemiş';

  @override
  String get upcomingAppointments => 'Yaklaşan Randevular';

  @override
  String get noUpcomingAppointments => 'Yaklaşan randevu yok';

  @override
  String get bookAppointment => 'Randevu Al';

  @override
  String get latestProgress => 'Son İlerleme';

  @override
  String get noProgressRecord => 'İlerleme kaydı yok';

  @override
  String get recordProgress => 'Kaydet';

  @override
  String get myTrainer => 'Eğitmeniniz';

  @override
  String get trainerNotLoaded => 'Eğitmen yüklenemedi';

  @override
  String get trainerInfoNotFound => 'Eğitmen bilgisi bulunamadı';

  @override
  String get leaveTrainer => 'Üyeliği Bırak';

  @override
  String get leaveTrainerTitle => 'Üyeliği Bırak';

  @override
  String leaveTrainerConfirm(String ptName) {
    return '$ptName ile üyeliğinizi sonlandırmak istiyor musunuz?';
  }

  @override
  String remainingSessionsWarning(int count) {
    return '$count kalan seansınız bulunuyor.';
  }

  @override
  String get yesLeave => 'Evet, Bırak';

  @override
  String get noPtAssigned => 'PT Atanmamış';

  @override
  String get findPtBannerSub =>
      'PT bularak antrenmanlarınıza başlayabilirsiniz';

  @override
  String get findPt => 'PT Bul';

  @override
  String get myPrograms => 'Programım';

  @override
  String get lastWeight => 'Son kilo';

  @override
  String get myMembers => 'Üyelerim';

  @override
  String get searchMember => 'Üye ara...';

  @override
  String get noMembersYetFull => 'Henüz üyeniz yok';

  @override
  String get addMemberHint => 'Üye eklemek için + butonuna tıklayın';

  @override
  String get addMember => 'Üye Ekle';

  @override
  String get searchNoResult => 'Arama sonucu bulunamadı';

  @override
  String get memberNotFound => 'Üye bulunamadı';

  @override
  String get sendMessage => 'Mesaj Gönder';

  @override
  String chatOpenError(String error) {
    return 'Mesaj açılamadı: $error';
  }

  @override
  String get addMemberTitle => 'Üye Ekle';

  @override
  String get memberEmail => 'Üye E-posta';

  @override
  String get goal => 'Hedef';

  @override
  String get goalHint => 'Kilo vermek, kas yapmak...';

  @override
  String get notes => 'Notlar';

  @override
  String invitationSent(String name) {
    return '$name adresine davet gönderildi';
  }

  @override
  String get memberNotFoundByEmail =>
      'Bu e-posta ile kayıtlı üye bulunamadı. Önce üye kayıt olmalıdır.';

  @override
  String get calendarTitle => 'Takvim';

  @override
  String get sessionDetailTitle => 'Seans Detayı';

  @override
  String get deleteSession => 'Seansı Sil';

  @override
  String get deleteSessionConfirm => 'Bu seansı silmek istiyor musunuz?';

  @override
  String get deleteError => 'Silme Hatası';

  @override
  String get close => 'Kapat';

  @override
  String get myAppointments => 'Randevularım';

  @override
  String get tabCalendar => 'Takvim';

  @override
  String get tabHistory => 'Geçmişim';

  @override
  String get requestAppointment => 'Randevu Talep Et';

  @override
  String get noDayAppointment => 'Bu gün randevu yok';

  @override
  String appointmentsCount(int count) {
    return '$count randevum';
  }

  @override
  String sessionDurationMin(int count) {
    return '$count dk seans';
  }

  @override
  String get ptBusy => 'PT dolu';

  @override
  String get ptBusyPersonal => 'PT meşgul';

  @override
  String get personalActivity => 'Kişisel etkinlik';

  @override
  String get passiveMemberTitle => 'Pasif Üye';

  @override
  String get passiveMemberContent =>
      'Randevu alabilmek için aktif olmanız gerekiyor. Eğitmeninize aktivasyon isteği göndermek ister misiniz?';

  @override
  String get sendRequest => 'İstek Gönder';

  @override
  String get activationRequestSent => 'Aktivasyon isteği gönderildi';

  @override
  String get dateAndTime => 'Tarih ve Saat';

  @override
  String get timeConflict => 'Bu saatte zaten randevunuz var';

  @override
  String get ptNotAvailable => 'PT bu saatte müsait değil';

  @override
  String sessionDurationLabel(int count) {
    return 'Seans süresi: $count dk';
  }

  @override
  String get durationLabel => 'Süre (dk):';

  @override
  String get findPtEnterEmail => 'PT\'nizi bulmak için e-posta adresini girin';

  @override
  String get ptEmail => 'PT E-posta';

  @override
  String get linkPt => 'PT\'yi Bağla';

  @override
  String get ptNotFoundByEmail => 'Bu e-posta ile kayıtlı PT bulunamadı';

  @override
  String get editAppointment => 'Randevu Düzenle';

  @override
  String get onlyPendingCanEdit => 'Sadece bekleyen talepler düzenlenebilir';

  @override
  String get completedCount => 'Tamamlanan';

  @override
  String get totalDuration => 'Toplam süre';

  @override
  String get upcomingMySessions => 'Yaklaşan Seanslarım';

  @override
  String get completedSessions => 'Tamamlanan Seanslar';

  @override
  String get noCompletedSessions => 'Henüz tamamlanan seans yok';

  @override
  String get noCompletedSessionsSub =>
      'Onaylanan seanslarınız tamamlandıkça burada görünecek';

  @override
  String get bookingConfirmTitle => 'Randevu Onayla';

  @override
  String get appointmentDetails => 'Randevu Detayları';

  @override
  String get waitingPtApproval =>
      'Randevunuz PT\'niz tarafından onaylanmayı bekleyecektir.';

  @override
  String get goToMyAppointments => 'Randevularıma Git';

  @override
  String get addPersonalEvent => 'Kişisel Etkinlik Ekle';

  @override
  String get eventTitle => 'Başlık';

  @override
  String get eventTitleHint => 'Yoga, antrenman...';

  @override
  String get memberCalendarTitle => 'Takvimim';

  @override
  String get progressTitle => 'İlerleme Takibi';

  @override
  String get noProgressYet => 'Henüz ilerleme kaydı yok';

  @override
  String get addMeasurements => 'Kilo ve ölçü bilgilerinizi kaydedin';

  @override
  String get addRecord => 'Kayıt Ekle';

  @override
  String get weightChart => 'Kilo Grafiği';

  @override
  String get addProgressTitle => 'İlerleme Ekle';

  @override
  String get progressSaved => 'İlerleme kaydedildi';

  @override
  String get saving => 'Kaydediliyor...';

  @override
  String get addProgressPhoto => 'İlerleme Fotoğrafı Ekle';

  @override
  String get enterAtLeastOneMeasurement => 'En az bir ölçüm girin';

  @override
  String get weight => 'Kilo (kg)';

  @override
  String get chest => 'Göğüs (cm)';

  @override
  String get waist => 'Bel (cm)';

  @override
  String get hips => 'Kalça (cm)';

  @override
  String get bicep => 'Biceps (cm)';

  @override
  String get thigh => 'Uyluk (cm)';

  @override
  String get bodyFat => 'Yağ Oranı (%)';

  @override
  String get date => 'Tarih';

  @override
  String get messagesTitle => 'Mesajlar';

  @override
  String get noMessagesYet => 'Henüz mesajınız yok';

  @override
  String get startMessaging => 'PT\'niz veya üyeniz ile mesajlaşmaya başlayın';

  @override
  String get typeMessage => 'Mesaj yaz...';

  @override
  String get earningsTitle => 'Gelir Takibi';

  @override
  String get packageManagement => 'Paket Yönetimi';

  @override
  String get totalEarnings => 'Toplam Gelir';

  @override
  String get pendingPayments => 'Bekleyen Ödemeler';

  @override
  String get completedPayments => 'Tamamlanan Ödemeler';

  @override
  String get noEarningsYet => 'Henüz gelir kaydı yok';

  @override
  String get paymentTitle => 'Ödeme';

  @override
  String get paymentHistoryTitle => 'Ödeme Geçmişi';

  @override
  String get noPaymentsYet => 'Henüz ödeme yok';

  @override
  String get programListTitle => 'Programlar';

  @override
  String get noProgramsYet => 'Henüz program oluşturulmamış';

  @override
  String get createProgram => 'Program Oluştur';

  @override
  String get programDetailTitle => 'Program Detayı';

  @override
  String get assignToMember => 'Üyeye Ata';

  @override
  String get memberProgramsTitle => 'Programlarım';

  @override
  String get noProgramAssigned => 'Henüz program atanmamış';

  @override
  String get workoutDetailTitle => 'Antrenman Detayı';

  @override
  String get invitationListTitle => 'Davetler';

  @override
  String get noPendingInvitations => 'Bekleyen davet yok';

  @override
  String get accept => 'Kabul Et';

  @override
  String get reject => 'Reddet';

  @override
  String get findPtTitle => 'PT Bul';

  @override
  String get searchPt => 'PT ara...';

  @override
  String get noPtFound => 'PT bulunamadı';

  @override
  String get profileTitle => 'Profil';

  @override
  String get noName => 'İsim yok';

  @override
  String get rolePt => 'Personal Trainer';

  @override
  String get roleMember => 'Üye';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get language => 'Dil';

  @override
  String get appearance => 'Görünüm';

  @override
  String get helpGuide => 'Kullanım Kılavuzu';

  @override
  String get workingHours => 'Çalışma Saatleri';

  @override
  String get settingsSection => 'Ayarlar';

  @override
  String get supportSection => 'Destek';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get notifSettings => 'Bildirim Ayarları';

  @override
  String get notifOn => 'Bildirimler Açık';

  @override
  String get notifOff => 'Bildirimler Kapalı';

  @override
  String get notifOnSub => 'Randevu ve seans bildirimleri alıyorsunuz';

  @override
  String get notifOffSub => 'Randevu ve seans bildirimleri için izin gerekli';

  @override
  String get openSystemSettings => 'Sistem Ayarlarını Aç';

  @override
  String get requestPermission => 'İzin İste';

  @override
  String get appearanceTitle => 'Görünüm';

  @override
  String get themeSystem => 'Sistem Varsayılanı';

  @override
  String get themeSystemSub => 'Cihazınızın temasını takip eder';

  @override
  String get themeLight => 'Açık Tema';

  @override
  String get themeLightSub => 'Her zaman açık renk tema';

  @override
  String get themeDark => 'Koyu Tema';

  @override
  String get themeDarkSub => 'Her zaman koyu renk tema';

  @override
  String get themeLabelLight => '☀️  Açık';

  @override
  String get themeLabelDark => '🌙  Koyu';

  @override
  String get themeLabelSystem => '⚙️  Sistem';

  @override
  String get languageTitle => 'Dil / Language';

  @override
  String get signOutTitle => 'Çıkış Yap';

  @override
  String get signOutConfirm => 'Hesabınızdan çıkmak istediğinize emin misiniz?';

  @override
  String get editName => 'İsim Düzenle';

  @override
  String get photoUpdated => 'Profil fotoğrafı güncellendi';

  @override
  String get photoFailed => 'Fotoğraf yüklenemedi';

  @override
  String get nameUpdated => 'İsim güncellendi';

  @override
  String get updateFailed => 'Güncellenemedi';

  @override
  String get messaging => 'Mesajlaşma';

  @override
  String get chatEmptyMessage => 'Henüz mesaj yok.\nMerhaba diyerek başlayın!';

  @override
  String sendFailed(String error) {
    return 'Gönderilemedi: $error';
  }

  @override
  String get noEventToday => 'Bu gün etkinlik yok';

  @override
  String get addSessionSubtitle => 'Üye ile antrenman seansı planla';

  @override
  String get addPersonalEventSubtitle => 'Antrenman, not veya hatırlatıcı ekle';

  @override
  String get addPersonalEventSubtitleMember =>
      'Antrenman, not veya hatırlatıcı ekleyin';

  @override
  String get createSession => 'Seans Oluştur';

  @override
  String get eventConflict => 'Bu saatte çakışan etkinlik var';

  @override
  String get sessionConflict => 'Bu saatte çakışan seans var';

  @override
  String get selectMember => 'Üye Seç';

  @override
  String get member => 'Üye';

  @override
  String get time => 'Saat';

  @override
  String get appointmentRequest => 'Randevu Talebi';

  @override
  String get appointmentRequestSub => 'Eğitmeninizden randevu isteyin';

  @override
  String get noEventForDay => 'Bu gün için etkinlik yok';

  @override
  String get ptAppointment => 'PT Randevusu';

  @override
  String get statusConfirmed => 'Onaylandı';

  @override
  String get statusPending => 'Bekliyor';

  @override
  String get statusCompleted => 'Tamamlandı';

  @override
  String get editEvent => 'Etkinliği Düzenle';

  @override
  String get addEvent => 'Etkinlik Ekle';

  @override
  String get titleRequired => 'Başlık gerekli';

  @override
  String get duration => 'Süre';

  @override
  String get notesOptional => 'Notlar (İsteğe bağlı)';

  @override
  String get setPassive => 'Pasif Yap';

  @override
  String get setActive => 'Aktif Yap';

  @override
  String get removeMember => 'Üyeyi Sil';

  @override
  String get overview => 'Genel Bakış';

  @override
  String get programs => 'Programlar';

  @override
  String get sessionsTab => 'Seanslar';

  @override
  String get notSpecified => 'Belirtilmemiş';

  @override
  String get joinDate => 'Katılım Tarihi';

  @override
  String get startingWeightLabel => 'Başlangıç Kilosu';

  @override
  String get heightLabel => 'Boy';

  @override
  String get phone => 'Telefon';

  @override
  String get bodyMeasurements => 'Vücut Ölçüleri (cm)';

  @override
  String get leg => 'Bacak';

  @override
  String get armBicep => 'Kol (bicep)';

  @override
  String get myPackages => 'Paketlerim';

  @override
  String get pendingApproval => 'Onay Bekliyor';

  @override
  String get recentTransactions => 'Son İşlemler';

  @override
  String get remainingSessionRights => 'kalan seans hakkı';

  @override
  String get noPtPackagesSub =>
      'PT\'niz sizi sisteme ekledikten sonra paketleri görebilirsiniz';

  @override
  String get buyPackage => 'Paket Satın Al';

  @override
  String get purchase => 'Satın Al';

  @override
  String get paymentRequestCreated =>
      'Ödeme talebiniz oluşturuldu. PT\'niz onayladığında seans hakkınız yüklenecektir.';

  @override
  String get noPackagesYet => 'Henüz paket oluşturmadınız';

  @override
  String get noPackagesYetSub => 'Üyeleriniz için seans paketi oluşturun';

  @override
  String get noPackagesAvailable => 'Satın alınacak paket bulunmuyor';

  @override
  String get addPackage => 'Paket Ekle';

  @override
  String get editPackage => 'Paketi Düzenle';

  @override
  String get newPackage => 'Yeni Paket';

  @override
  String get packageName => 'Paket Adı';

  @override
  String get sessionCountLabel => 'Seans Sayısı';

  @override
  String get sessionDuration => 'Seans Süresi';

  @override
  String get priceTry => 'Fiyat (TRY)';

  @override
  String get descriptionOptional => 'Açıklama (İsteğe bağlı)';

  @override
  String get memberSpecificPackage => 'Üyeye özel paket';

  @override
  String get createPackage => 'Paketi Oluştur';

  @override
  String get deletePackageTitle => 'Paketi Sil';

  @override
  String get deletePackageConfirm => 'Bu paketi silmek istiyor musunuz?';

  @override
  String get packageDeleted => 'Paket silindi';

  @override
  String deleteFailed(String error) {
    return 'Silinemedi: $error';
  }

  @override
  String get special => 'Özel';

  @override
  String get edit => 'Düzenle';

  @override
  String get deactivate => 'Pasife Al';

  @override
  String get activate => 'Aktive Et';

  @override
  String get enterValidNumber => 'Geçerli bir sayı girin';

  @override
  String get selectMemberHint => 'Üye seç';

  @override
  String get selectMemberRequired => 'Üye seçin';

  @override
  String get deleteProgram => 'Programı Sil';

  @override
  String get deleteProgramConfirm =>
      'Bu programı kalıcı olarak silmek istiyor musunuz?';

  @override
  String get ok => 'Tamam';

  @override
  String get restDay => 'Dinlenme';

  @override
  String get restDayLabel => 'Dinlenme Günü';

  @override
  String get restDayFull => 'Dinlenme Günü 🛌';

  @override
  String get noExercisesYet => 'Henüz egzersiz eklenmedi';

  @override
  String get myWorkoutProgram => 'Antrenman Programım';

  @override
  String get programName => 'Program Adı';

  @override
  String get programUpdated => 'Program güncellendi';

  @override
  String get programCreated => 'Program oluşturuldu';

  @override
  String get weekCountLabel => 'Hafta Sayısı:';

  @override
  String get addWorkout => 'Antrenman Ekle';

  @override
  String get addExercise => 'Egzersiz Ekle';

  @override
  String get exerciseName => 'Egzersiz Adı';

  @override
  String get sets => 'Set';

  @override
  String get reps => 'Tekrar';

  @override
  String get weightKg => 'Ağırlık (kg)';

  @override
  String get restSeconds => 'Dinlenme (sn)';

  @override
  String get noteLabel => 'Not';

  @override
  String get selectMemberSnack => 'Lütfen bir üye seçin';

  @override
  String get membersLoadFailed => 'Üyeler yüklenemedi';

  @override
  String get editProgram => 'Programı Düzenle';

  @override
  String get sendingInvitation => 'Davet gönderiliyor...';

  @override
  String get memberInfo => 'Üye Bilgileri';

  @override
  String get memberEmailInstructions =>
      'Üyenin e-posta adresiyle arama yapın. Üye önce uygulamaya kayıt olmalı.';

  @override
  String get goalOptional => 'Hedef (İsteğe bağlı)';

  @override
  String get goalHintAlt => 'Kilo verme, kas kazanma...';

  @override
  String get notesHint => 'Özel durumlar, sağlık notları...';

  @override
  String get sendInvitation => 'Davet Gönder';

  @override
  String memberMadeActive(String name) {
    return '$name aktif yapıldı';
  }

  @override
  String memberMadePassive(String name) {
    return '$name pasif yapıldı';
  }

  @override
  String memberDeleteConfirm(String name) {
    return '$name kalıcı olarak silinecek. Bu işlem geri alınamaz.';
  }

  @override
  String get noAssignedPrograms =>
      'PT\'niz size bir program atadığında burada görünür';

  @override
  String get weekLabel => 'Hafta';

  @override
  String get programNotFound => 'Program bulunamadı';

  @override
  String get helpGuideTitle => 'Kullanım Kılavuzu';

  @override
  String get ptRequestTitle => 'PT\'ye İstek Gönder';

  @override
  String ptRequestContent(String ptName) {
    return '$ptName adlı eğitmene katılım isteği göndermek istiyor musunuz?\n\nEğitmen isteği onayladıktan sonra bağlantı kurulacak.';
  }

  @override
  String requestSentTo(String ptName) {
    return '$ptName adlı eğitmene istek gönderildi';
  }

  @override
  String get searchByNameOrEmail => 'İsim veya e-posta ile ara';

  @override
  String get searchHintFull => 'PT aramak için isim veya\ne-posta girin';

  @override
  String noResultFor(String query) {
    return '\"$query\" için sonuç bulunamadı';
  }

  @override
  String ptConnected(String ptName) {
    return '$ptName ile bağlantı kuruldu';
  }

  @override
  String get invitationRejected => 'Davet reddedildi';

  @override
  String invitationDate(String date) {
    return 'Davet: $date';
  }

  @override
  String get noInvitationsYetSub =>
      'PT\'niz sizi davet ettiğinde burada görünür';

  @override
  String memberDeleteError(String error) {
    return 'Silme hatası: $error';
  }

  @override
  String sessionsLeft(int count) {
    return '$count seans kaldı';
  }

  @override
  String get noMemberPrograms => 'Henüz program yok';

  @override
  String get noMemberSessions => 'Henüz seans yok';

  @override
  String get personalEvent => 'Kişisel Etkinlik';

  @override
  String get deleteEventTitle => 'Etkinliği Sil';

  @override
  String deleteEventConfirm(String title) {
    return '\"$title\" etkinliğini silmek istiyor musunuz?';
  }

  @override
  String get anonymousMember => 'İsimsiz Üye';

  @override
  String sessionsCount(int count) {
    return '$count seans';
  }

  @override
  String eventsCount(int count) {
    return '$count etkinlik';
  }

  @override
  String get noProgramsYetSub => 'Üyeleriniz için antrenman programı oluşturun';

  @override
  String weekProgramLabel(int count) {
    return '$count Hafta Programı';
  }

  @override
  String exercisesCount(int count) {
    return '$count egzersiz';
  }

  @override
  String completedPaymentsCount(int count) {
    return '$count Ödeme';
  }

  @override
  String pendingPaymentsCount(int count) {
    return '$count Bekleyen';
  }

  @override
  String pendingApprovalCount(int count) {
    return 'Onay Bekleyen ($count)';
  }

  @override
  String get noPaymentsYetSub =>
      'Üyeleriniz paket satın aldığında burada görünür';

  @override
  String get transactionHistory => 'İşlem Geçmişi';

  @override
  String sessionsLoadedToMember(int count) {
    return '$count seans üyeye yüklendi';
  }

  @override
  String get paymentRequestRejected => 'Ödeme talebi reddedildi';

  @override
  String get statusLabel => 'Durum';

  @override
  String get cancelSession => 'İptal Et';

  @override
  String get markAsCompleted => 'Tamamlandı Olarak İşaretle';

  @override
  String durationMinutesValue(int minutes) {
    return '$minutes dakika';
  }

  @override
  String get requestRejected => 'İstek reddedildi';

  @override
  String memberAddedSnack(String name) {
    return '$name üye olarak eklendi';
  }

  @override
  String get restDayMessage => 'Bugün dinlenme günü 🛌 İyi dinlenmeler!';

  @override
  String memberActivatedSnack(String name) {
    return '$name aktif hale getirildi';
  }

  @override
  String get appSubtitle => 'Kişisel Antrenman Uygulaması';

  @override
  String get weightShort => 'Kilo';

  @override
  String get waistShort => 'Bel';

  @override
  String get chestShort => 'Göğüs';

  @override
  String get hipsShort => 'Kalça';

  @override
  String purchaseDialogContent(String name, String price, int count) {
    return '$name paketini $price karşılığında satın almak istiyor musunuz?\n\n$count seans hakkı PT onayından sonra hesabınıza yüklenecektir.';
  }

  @override
  String get helpWelcomeTitle => 'BookMyPT\'e Hoş Geldiniz!';

  @override
  String get helpMemberIntroBody =>
      'Bu uygulama sayesinde eğitmeninizle kolayca randevu alabilir, ilerlemenizi takip edebilir ve seans paketlerinizi yönetebilirsiniz.';

  @override
  String get helpPtIntroBody =>
      'Bu uygulama sayesinde üyelerinizin randevularını kolayca yönetebilir, seans paketleri oluşturabilir ve kazançlarınızı takip edebilirsiniz.';

  @override
  String get helpHomeTitle => 'Ana Ekran';

  @override
  String get helpHomeItem1Title => 'Eğitmen Bilgileri';

  @override
  String get helpHomeItem1Body =>
      'Atanmış PT\'niz, kalan seans hakkınız ve yaklaşan randevularınız ana ekranda bir bakışta görünür.';

  @override
  String get helpHomeItem2Title => 'PT Atanmamışsa';

  @override
  String get helpHomeItem2Body =>
      '\"PT Bul\" özelliği üzerinden e-posta adresiyle eğitmeninizi sisteme ekleyebilirsiniz. PT sizi sisteme aldıktan sonra randevu ve paket işlemleri aktif olur.';

  @override
  String get helpHomeItem3Title => 'Üyeliği Bırak';

  @override
  String get helpHomeItem3Body =>
      'PT kartındaki \"Üyeliği Bırak\" butonuyla eğitmeninizle bağlantınızı kesebilirsiniz. Kalan seans haklarınız bu işlemden etkilenmez.';

  @override
  String get helpCalendarTitle => 'Randevularım';

  @override
  String get helpCalendarItem1Title => 'Randevu Talebi Oluşturma';

  @override
  String get helpCalendarItem1Body =>
      'Sağ üstteki + butonuna basın, tarih ve saati seçin. Paketinizde seans süresi tanımlıysa otomatik belirlenir. Talebiniz PT onayına gönderilir.';

  @override
  String get helpCalendarItem2Title => 'Takvim Sekmesi';

  @override
  String get helpCalendarItem2Body =>
      'Günlük bazda tüm randevularınızı görürsünüz. Mavi nokta kendi randevularınızı, gri nokta PT\'nin meşgul olduğu saatleri gösterir. Bekleyen taleplerinize tıklayarak tarih veya saati değiştirebilirsiniz.';

  @override
  String get helpCalendarItem3Title => 'Geçmişim Sekmesi';

  @override
  String get helpCalendarItem3Body =>
      'Tamamlanan seanslarınızın sayısı ve toplam süresini burada görürsünüz. Yaklaşan onaylı randevularınız da bu sekmede listelenir.';

  @override
  String get helpCalendarItem4Title => 'Randevu Durumları';

  @override
  String get helpCalendarItem4Body =>
      '• Bekliyor: Talep oluşturuldu, PT onayı bekleniyor.\n• Onaylandı: PT kabul etti, seans gerçekleşecek.\n• Tamamlandı: Seans gerçekleşti.\n• İptal: Seans iptal edildi.';

  @override
  String get helpMyCalendarTitle => 'Takvimim';

  @override
  String get helpMyCalendarItem1Title => 'Kişisel Etkinlik Ekleme';

  @override
  String get helpMyCalendarItem1Body =>
      'Sağ üstteki + butonuyla kişisel etkinlikler ekleyebilirsiniz (antrenman, toplantı, tatil vb.). Bu etkinlikler yalnızca sizin takviminizde görünür.';

  @override
  String get helpMyCalendarItem2Title => 'PT\'nin Müsaitliği';

  @override
  String get helpMyCalendarItem2Body =>
      'PT\'nizin başka üyelerle olan randevuları ve kişisel etkinlikleri gri renkte görünür. Böylece randevu talebinde bulunmadan önce müsaitliği kontrol edebilirsiniz.';

  @override
  String get helpMyCalendarItem3Title => 'Etkinlik Düzenleme';

  @override
  String get helpMyCalendarItem3Body =>
      'Eklediğiniz kişisel etkinliklere tıklayarak tarih, saat, süre ve notlarını düzenleyebilir ya da silebilirsiniz.';

  @override
  String get helpPackagesTitle => 'Paketlerim';

  @override
  String get helpPackagesItem1Title => 'Paket Satın Alma';

  @override
  String get helpPackagesItem1Body =>
      'PT\'nizin sunduğu seans paketlerini bu ekranda görürsünüz. \"Satın Al\" butonuna bastığınızda ödeme talebi oluşur; PT onayladıktan sonra seans hakkınız hesabınıza eklenir.';

  @override
  String get helpPackagesItem2Title => 'Üyeye Özel Paketler';

  @override
  String get helpPackagesItem2Body =>
      'PT\'niz sizin için özel fiyatlı veya süreli paket oluşturmuş olabilir. Bu paketleri yalnızca siz görebilirsiniz.';

  @override
  String get helpPackagesItem3Title => 'Ödeme Geçmişi';

  @override
  String get helpPackagesItem3Body =>
      'Tüm ödeme talepleriniz ve durumları (Bekliyor / Tamamlandı) ekranın üst kısmında listelenir.';

  @override
  String get helpProgressTitle => 'İlerleme';

  @override
  String get helpProgressItem1Title => 'Ölçüm Girişi';

  @override
  String get helpProgressItem1Body =>
      'Kilo, boy ve vücut ölçülerinizi kaydedebilirsiniz. Fotoğraf ekleyerek görsel ilerlemenizi de takip edebilirsiniz.';

  @override
  String get helpProgressItem2Title => 'Geçmişe Dönük Giriş';

  @override
  String get helpProgressItem2Body =>
      'Girişi unuttuğunuz günler için tarih seçerek geçmişe dönük kayıt yapabilirsiniz.';

  @override
  String get helpProgressItem3Title => 'Grafik Takibi';

  @override
  String get helpProgressItem3Body =>
      'Kaydettiğiniz ölçümler grafik olarak gösterilir. Zaman içindeki değişiminizi kolayca izleyebilirsiniz.';

  @override
  String get helpMessagesTitle => 'Mesajlar';

  @override
  String get helpMemberMessagesItem1Title => 'PT ile İletişim';

  @override
  String get helpMemberMessagesItem1Body =>
      'PT\'nizle doğrudan mesajlaşabilirsiniz. Seans değişiklikleri, sorular veya antrenman notları için bu ekranı kullanın.';

  @override
  String get helpPtHomeItem1Title => 'Günlük Özet';

  @override
  String get helpPtHomeItem1Body =>
      'Bugünkü randevularınız, bekleyen talepler ve son üye hareketleri ana ekranda listelenir.';

  @override
  String get helpPtHomeItem2Title => 'Bekleyen Talepler';

  @override
  String get helpPtHomeItem2Body =>
      'Üyelerinizin randevu taleplerini buradan hızlıca onaylayabilir veya reddedebilirsiniz. Onay verdiğinizde üyeye bildirim gider.';

  @override
  String get helpPtHomeItem3Title => 'Aktivasyon İstekleri';

  @override
  String get helpPtHomeItem3Body =>
      'Pasif üyeler aktivasyon isteği gönderebilir. Bu istekleri ana ekrandan yönetebilirsiniz.';

  @override
  String get helpPtCalendarTitle => 'Takvim';

  @override
  String get helpPtCalendarItem1Title => 'Randevu Yönetimi';

  @override
  String get helpPtCalendarItem1Body =>
      'Tüm üyelerinizin seansları takvimde renkli noktalarla görünür. Bir güne tıklayarak o günkü detaylı listeye geçebilirsiniz.';

  @override
  String get helpPtCalendarItem2Title => 'Kişisel Etkinlik';

  @override
  String get helpPtCalendarItem2Body =>
      'Sağ üstteki + butonu ile tatil, toplantı gibi kişisel etkinlikler ekleyebilirsiniz. Bu saatler üyelerin randevu takviminde \"meşgul\" olarak görünür.';

  @override
  String get helpPtCalendarItem3Title => 'Seans Detayı';

  @override
  String get helpPtCalendarItem3Body =>
      'Listedeki bir seansa tıklayarak detay ekranını açabilir, durumu güncelleyebilir (onayla / iptal / tamamla) ve notlar ekleyebilirsiniz.';

  @override
  String get helpPtMembersTitle => 'Üyeler';

  @override
  String get helpPtMembersItem1Title => 'Üye Ekleme';

  @override
  String get helpPtMembersItem1Body =>
      'Yeni üye eklemek için + butonuna basın ve üyenin bilgilerini girin. Sisteme eklenen üye size bağlanır ve randevu alabilir.';

  @override
  String get helpPtMembersItem2Title => 'Üye Yönetimi';

  @override
  String get helpPtMembersItem2Body =>
      'Üye kartına tıklayarak profil detayını görüntüleyebilir, kişisel hedef ve notlar ekleyebilir, kalan seans haklarını takip edebilirsiniz.';

  @override
  String get helpPtMembersItem3Title => 'Aktif / Pasif Durumu';

  @override
  String get helpPtMembersItem3Body =>
      'Üyeyi pasife aldığınızda o üye yeni randevu talebi oluşturamaz. Aktivasyon isteği gönderirse siz onaylarsınız.';

  @override
  String get helpPtPackagesTitle => 'Paket Yönetimi';

  @override
  String get helpPtPackagesItem1Title => 'Paket Oluşturma';

  @override
  String get helpPtPackagesItem1Body =>
      'Seans sayısı, süresi ve fiyatını belirleyerek paket oluşturabilirsiniz. Paketler tüm aktif üyelerinize görünür.';

  @override
  String get helpPtPackagesItem2Title => 'Üyeye Özel Paket';

  @override
  String get helpPtPackagesItem2Body =>
      '\"Üyeye özel\" seçeneğiyle belirli bir üye için özel fiyatlı paket tanımlayabilirsiniz. Bu paket yalnızca o üyenin Paketlerim ekranında görünür.';

  @override
  String get helpPtPackagesItem3Title => 'Seans Süresi';

  @override
  String get helpPtPackagesItem3Body =>
      'Pakette seans süresi belirtirseniz, o üye randevu alırken süre otomatik olarak belirlenir ve üye manuel seçim yapamaz.';

  @override
  String get helpPtEarningsTitle => 'Kazançlar & Ödemeler';

  @override
  String get helpPtEarningsItem1Title => 'Ödeme Onaylama';

  @override
  String get helpPtEarningsItem1Body =>
      'Üye paket satın aldığında ödeme talebi oluşur. Siz onayladığınızda üyenin seans hakkı otomatik olarak güncellenir ve üyeye bildirim gider.';

  @override
  String get helpPtEarningsItem2Title => 'Ödeme Reddetme';

  @override
  String get helpPtEarningsItem2Body =>
      'Ödemenin gerçekleşmediği durumlarda talebi reddedebilirsiniz. Seans hakkı eklenmez.';

  @override
  String get helpPtEarningsItem3Title => 'Kazanç Özeti';

  @override
  String get helpPtEarningsItem3Body =>
      'Aylık ve toplam kazanç özeti ekranın üst kısmında görünür.';

  @override
  String get helpPtMessagesItem1Title => 'Üye İletişimi';

  @override
  String get helpPtMessagesItem1Body =>
      'Tüm üyelerinizle ayrı ayrı mesajlaşabilirsiniz. Antrenman notları, diyet önerileri veya seans değişiklikleri için kullanın.';

  @override
  String get helpTipBody =>
      'Sorun yaşarsanız uygulamayı kapatıp yeniden açmayı deneyin. Bildirim almak için Profil → Bildirimler bölümünden bildirim izinlerini kontrol edin.';

  @override
  String get signInWithGoogle => 'Google ile Giriş Yap';

  @override
  String get noPendingRequests => 'Bekleyen istek yok';

  @override
  String get noPendingRequestsSub =>
      'Üyeler size katılmak için istek gönderdiğinde burada görünür';

  @override
  String get activationRequest => 'Aktivasyon isteği';

  @override
  String get joinRequest => 'Katılım isteği';

  @override
  String get programNameHint => 'Başlangıç Programı';

  @override
  String get programDescriptionHint => 'Program hakkında kısa bilgi';

  @override
  String get colorSchemeSection => 'Renk Şeması';

  @override
  String get colorSchemeClassic => 'Klasik';

  @override
  String get colorSchemeClassicSub => 'Varsayılan renk teması';

  @override
  String get colorSchemeSport => 'Spor';

  @override
  String get colorSchemeSportSub => 'Canlı ve enerjik renkler';

  @override
  String get deleteForMe => 'Benden Sil';

  @override
  String get deleteForEveryone => 'Herkesten Sil';

  @override
  String get messageDeleted => 'Bu mesaj silindi';

  @override
  String get groups => 'Gruplar';

  @override
  String get group => 'Grup';

  @override
  String get noGroupsYet => 'Henüz grup yok';

  @override
  String get createGroupHint => 'Grup oluşturmak için + butonuna tıklayın';

  @override
  String get createGroup => 'Grup Oluştur';

  @override
  String get editGroup => 'Grubu Düzenle';

  @override
  String get deleteGroup => 'Grubu Sil';

  @override
  String get deleteGroupConfirm =>
      'Bu grubu silmek istiyor musunuz? Geçmiş seans kayıtları korunur.';

  @override
  String get groupName => 'Grup Adı';

  @override
  String get groupNameHint => 'Sabah Grubu, Kilo Verme Grubu...';

  @override
  String get groupDescription => 'Açıklama';

  @override
  String get groupDescriptionHint => 'Grup hakkında kısa bilgi';

  @override
  String get groupColor => 'Grup Rengi';

  @override
  String get groupNeedMembers => 'En az bir üye seçmelisiniz';

  @override
  String get selectMembers => 'Üye Seç';

  @override
  String get selected => 'seçili';

  @override
  String get noActiveMembers => 'Aktif üye bulunamadı';

  @override
  String get members => 'Üyeler';

  @override
  String get noMembersInGroup => 'Grupta henüz üye yok';

  @override
  String get packages => 'Paketler';

  @override
  String get perMember => 'üye başına';

  @override
  String get inactive => 'Pasif';

  @override
  String get required => 'Zorunlu alan';

  @override
  String get price => 'Fiyat';

  @override
  String get sessionCount => 'Seans Sayısı';

  @override
  String get newSession => 'Yeni Seans';

  @override
  String get sessionDetail => 'Seans Detayı';

  @override
  String get dateTime => 'Tarih & Saat';

  @override
  String get attendance => 'Katılım';

  @override
  String get attended => 'katıldı';

  @override
  String get scheduled => 'Planlandı';

  @override
  String get completed => 'Tamamlandı';

  @override
  String get cancelled => 'İptal Edildi';

  @override
  String get sessionCompleted => 'Seans Tamamlandı';

  @override
  String get cancelSessionConfirm => 'Bu seansı iptal etmek istiyor musunuz?';

  @override
  String get noSessionsYet => 'Henüz seans yok';

  @override
  String get optionalNotes => 'Notlar (İsteğe bağlı)';

  @override
  String get participants => 'katılımcı';

  @override
  String get openChat => 'Sohbeti Aç';

  @override
  String get individual => 'Bireysel';

  @override
  String get groupPackages => 'Grup Paketleri';

  @override
  String get notInAnyGroup => 'Herhangi bir gruba üye değilsiniz';

  @override
  String get noGroupPackagesYet => 'Henüz grup paketi bulunmuyor';

  @override
  String get alreadyPurchased => 'Satın Alındı';

  @override
  String groupPurchaseConfirm(
      String name, String groupName, String price, int count) {
    return '$name paketini $groupName grubu için $price karşılığında satın almak istiyor musunuz?\n\n$count seans hakkı PT onayından sonra hesabınıza yüklenecektir.';
  }

  @override
  String get sendCancellationRequest => 'İptal Talebi Gönder';

  @override
  String get cancellationRequestSent => 'İptal Talebiniz Gönderildi';

  @override
  String get memberRequestedCancellation => 'Üye İptal Talep Etti';

  @override
  String get ptRequestedCancellation => 'Eğitmen İptal Talep Etti';

  @override
  String get acceptCancellation => 'İptali Onayla';

  @override
  String get rejectCancellation => 'Reddet';

  @override
  String get cancellationRequestConfirm =>
      'İptal talebiniz karşı tarafa iletilecek. Devam etmek istiyor musunuz?';

  @override
  String get sessionInFutureWarning => 'Gelecekteki bir seans tamamlanamaz';

  @override
  String get exerciseTypeStrength => 'Güç';

  @override
  String get exerciseTypeCardio => 'Kardio';

  @override
  String get exerciseTypeStretching => 'Esneme';

  @override
  String get durationMinLabel => 'Süre (dk)';

  @override
  String get distanceKmLabel => 'Mesafe (km)';

  @override
  String get holdSecLabel => 'Tutma Süresi (sn)';

  @override
  String get about => 'Hakkında';

  @override
  String get aboutTagline => 'Kişisel antrenör ve üye yönetim platformu';

  @override
  String get aboutVersionLabel => 'Sürüm';

  @override
  String get aboutReleaseDateLabel => 'Yayın Tarihi';

  @override
  String get aboutReleaseDateValue => 'Mayıs 2026';

  @override
  String get aboutDeveloperLabel => 'Geliştirici';

  @override
  String get aboutDeveloperName => 'BookMyPt Ekibi';

  @override
  String get aboutCopyright => '© 2026 BookMyPt. Tüm hakları saklıdır.';

  @override
  String get deleteChatTitle => 'Sohbeti Sil';

  @override
  String get deleteChatBody =>
      'Bu sohbet silindiğinde her iki taraf için de listeden kalkar. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?';

  @override
  String get chatDeleted => 'Sohbet silindi';

  @override
  String get helpCalendarItem5Title => 'Geçmiş Tarih Kısıtlaması';

  @override
  String get helpCalendarItem5Body =>
      'Geçmişe ait bir tarih veya saate randevu talebi oluşturamazsınız. Seçilen zamanın en az 5 dakika ileride olması gerekir.';

  @override
  String get helpPackagesItem4Title => 'Grup Paketleri';

  @override
  String get helpPackagesItem4Body =>
      'Eğitmeniniz sizi bir gruba dahil etmişse \"Gruplar\" sekmesinde o gruba ait paketleri satın alabilirsiniz. PT onayladıktan sonra seans hakkınız hesabınıza eklenir.';

  @override
  String get helpProgramsTitle => 'Programlarım';

  @override
  String get helpProgramsItem1Title => 'Antrenman Programı';

  @override
  String get helpProgramsItem1Body =>
      'PT\'niz size haftalık antrenman programı atayabilir. Programı hafta ve gün bazında inceleyebilir, tüm egzersiz detaylarına ulaşabilirsiniz.';

  @override
  String get helpProgramsItem2Title => 'Egzersiz Tipleri';

  @override
  String get helpProgramsItem2Body =>
      'Programlar üç farklı egzersiz tipinden oluşabilir: 💪 Güç (set/tekrar/ağırlık), 🏃 Kardio (süre/mesafe) ve 🧘 Esneme (set/tutma süresi).';

  @override
  String get helpMemberMessagesItem2Title => 'Grup Sohbetleri';

  @override
  String get helpMemberMessagesItem2Body =>
      'Eğitmeniniz sizi bir gruba dahil ederse grup sohbet odası otomatik oluşturulur. Tüm grup üyeleri ve PT grup sohbetine katılır.';

  @override
  String get helpMemberMessagesItem3Title => 'Sohbeti Sil';

  @override
  String get helpMemberMessagesItem3Body =>
      'Sohbet listesinde herhangi bir sohbete uzun basarak silme seçeneğine ulaşabilirsiniz. Sohbet silindiğinde her iki taraf için de listeden kaybolur.';

  @override
  String get helpPtProgramsTitle => 'Antrenman Programları';

  @override
  String get helpPtProgramsItem1Title => 'Program Oluşturma';

  @override
  String get helpPtProgramsItem1Body =>
      'Üye seçerek haftalık antrenman programı oluşturabilirsiniz. Hafta sayısını (1–12) belirleyin ve her güne egzersiz ekleyin. Cumartesi–Pazar varsayılan olarak dinlenme günüdür.';

  @override
  String get helpPtProgramsItem2Title => 'Egzersiz Tipleri';

  @override
  String get helpPtProgramsItem2Body =>
      'Güç (set/tekrar/ağırlık/dinlenme), Kardio (süre/mesafe) ve Esneme (set/tutma süresi) olmak üzere 3 farklı egzersiz tipi ekleyebilirsiniz. Egzersizi eklerken tipini seçiciyle belirleyin.';

  @override
  String get helpPtProgramsItem3Title => 'Aktif / Pasif Yönetimi';

  @override
  String get helpPtProgramsItem3Body =>
      'Üyenin program listesinde yalnızca aktif programlar görünür. Programı pasife alarak gizleyebilir, dilediğinizde tekrar aktif edebilirsiniz.';

  @override
  String get helpPtPackagesItem4Title => 'Grup Yönetimi';

  @override
  String get helpPtPackagesItem4Body =>
      '\"Gruplar\" sekmesinden birden fazla üyeyi bir grupta toplayabilirsiniz. Her grup için ayrı paket ve seans tanımlayabilirsiniz; grup oluşturulduğunda otomatik sohbet odası açılır. Grup silindiğinde sohbet odası da kaldırılır.';

  @override
  String get helpPtEarningsItem4Title => 'Anlık Bildirim';

  @override
  String get helpPtEarningsItem4Body =>
      'Üye paket satın aldığında anlık push bildirimi alırsınız. Bildirme dokunarak doğrudan Kazançlar ekranına ulaşabilirsiniz.';

  @override
  String get helpPtMessagesItem2Title => 'Grup Sohbetleri';

  @override
  String get helpPtMessagesItem2Body =>
      'Oluşturduğunuz her grup için otomatik sohbet odası açılır. Grup silindiğinde sohbet odası da listeden kaldırılır.';

  @override
  String get helpPtMessagesItem3Title => 'Sohbeti Sil';

  @override
  String get helpPtMessagesItem3Body =>
      'Sohbet listesinde herhangi bir sohbete uzun basarak silebilirsiniz. Sohbet silindiğinde her iki taraf için de listeden kaybolur.';
}
