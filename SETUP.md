# FitCoach — Kurulum Kılavuzu

## 1. Flutter Kurulumu

```bash
# Flutter SDK indir: https://flutter.dev/docs/get-started/install
flutter --version  # 3.x.x gerekli
```

## 2. Firebase Projesi Oluştur

1. [Firebase Console](https://console.firebase.google.com) → Yeni Proje
2. Proje adı: `fitcoach`
3. Servisleri etkinleştir:
   - **Authentication** → E-posta/Şifre + Google
   - **Cloud Firestore** → Production mode
   - **Storage** → Başlat
   - **Cloud Messaging** → Etkinleştir

## 3. FlutterFire CLI ile Bağlan

```bash
# FlutterFire CLI kur
dart pub global activate flutterfire_cli

# Projeye bağla (lib/firebase_options.dart oluşturur)
cd /Users/mesutaltintas/Projeler/BookMyPT
flutterfire configure --project=YOUR_PROJECT_ID

# main.dart içindeki yorumları kaldır:
# await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

## 4. Bağımlılıkları Yükle

```bash
flutter pub get
```

## 5. Firestore Kurallarını Deploy Et

```bash
# Firebase CLI kur
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules
firebase deploy --only storage
firebase deploy --only firestore:indexes
```

## 6. Google Sign-In Ayarları

### Android
- `android/app/google-services.json` dosyasını Firebase Console'dan indir
- SHA-1 parmak izini Firebase'e ekle:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

### iOS
- `ios/Runner/GoogleService-Info.plist` dosyasını Firebase Console'dan indir

## 7. Stripe Entegrasyonu (İsteğe bağlı)

```dart
// pubspec.yaml'da flutter_stripe zaten var
// lib/features/m_payment/presentation/screens/payment_screen.dart'ta:
// Stripe.publishableKey = 'pk_test_YOUR_KEY';
```

## 8. Bildirimler için flutter_local_notifications

pubspec.yaml'a ekle:
```yaml
flutter_local_notifications: ^17.0.0
```

## 9. Projeyi Çalıştır

```bash
flutter run
```

---

## Klasör Yapısı

```
lib/
  core/
    constants/    → AppConstants (collection isimleri, sabitler)
    router/       → GoRouter konfigürasyonu
    theme/        → Material 3 tema (PT: teal, Üye: blue)
    utils/        → Extensions, Validators
  features/
    auth/         → Login, Register, RoleSelection, ForgotPassword
    pt_members/   → Dashboard, MemberList, MemberDetail, AddMember
    pt_programs/  → ProgramList, ProgramDetail, CreateProgram
    pt_calendar/  → PtCalendar, SessionDetail
    pt_earnings/  → EarningsScreen, PackageManagement
    m_booking/    → MemberDashboard, BookingScreen
    m_programs/   → MemberPrograms, WorkoutDetail
    m_progress/   → ProgressScreen, AddProgress
    m_payment/    → PaymentScreen, PaymentHistory
    m_chat/       → ChatList, ChatScreen
  shared/
    models/       → UserModel, SessionModel, ProgramModel, ...
    services/     → NotificationService, ThemeService
    widgets/      → AppLoading, AppError, AppEmpty, UserAvatar, ...
  main.dart
```

## Firestore Veri Modeli

| Collection | Belge | Alanlar |
|---|---|---|
| `users/{uid}` | Kullanıcı | role, name, email, photoUrl, fcmToken |
| `pts/{ptId}/members/{memberId}` | PT-Üye ilişkisi | name, email, goal, notes, remainingSessions |
| `pts/{ptId}/packages/{pkgId}` | Paket tanımı | name, sessionCount, price, currency |
| `programs/{id}` | Antrenman programı | ptId, memberId, title, weeks[] |
| `sessions/{id}` | Seans | ptId, memberId, dateTime, status |
| `payments/{id}` | Ödeme | memberId, ptId, amount, packageName, status |
| `progress/{id}` | İlerleme kaydı | memberId, date, weight, measurements, photoUrl |
| `chats/{chatId}/messages/{msgId}` | Mesaj | senderId, text, createdAt, read |
