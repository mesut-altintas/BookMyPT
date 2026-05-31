# BookMyPt — Claude Code Rehberi

## Proje

Flutter + Firebase tabanlı PT (Personal Trainer) randevu ve takip uygulaması.
İki kullanıcı rolü var: **PT** ve **Üye (member)**.

## Çalışma Dizini

**Her zaman `C:\Dev\BookMyPt` kullan.** iCloud dizinini (`C:\Users\Mesut2023\iCloudDrive\EKS\Projeler\BookMyPt_Yeni`) kullanma.

## Flutter & Build

```bash
# Flutter yolu (PATH'te değil, tam yol kullan)
C:\flutter\bin\flutter.bat

# Android APK build + yükle
C:\flutter\bin\flutter.bat build apk --release
C:\flutter\bin\flutter.bat install --device-id R6GL1028KRR   # SM A176B

# iOS — GitHub Actions ile (manuel tetikle)
gh workflow run "iOS TestFlight" --ref main
```

## Firebase

```bash
# Deploy (npx ile çalışır, firebase global değil)
npx firebase-tools deploy --only functions
npx firebase-tools deploy --only firestore:rules
npx firebase-tools functions:log --only functionName
```

- **Project ID:** `bookmypt`
- **Cloud Functions:** Gen 1 (v1), `firebase-functions/v1` import, Node 18
- **Functions dosyası:** `functions/index.js`
- **Firestore kuralları:** `firestore.rules`

## Mimari

```
lib/
  core/           # router, theme, constants, utils
  features/
    auth/         # giriş/kayıt
    pt_calendar/  # PT takvim, seans yönetimi
    pt_members/   # üye listesi, detay
    pt_earnings/  # gelir takibi, paket yönetimi
    pt_programs/  # program yönetimi
    pt_groups/    # grup dersleri (GroupSession, GroupPayment)
    m_booking/    # üye randevu ekranı
    m_calendar/   # üye takvim + kişisel etkinlikler
    m_payment/    # üye ödeme geçmişi
  shared/
    models/       # SessionModel, PaymentModel, PersonalEventModel, ...
    services/     # NotificationService (FCM)
    widgets/      # AppLoading, AppError, StatusBadge, ...
```

**State management:** Riverpod 2.x  
**Router:** GoRouter (ShellRoute)  
**Backend:** Firestore (realtime streams)

## PT Navigation

PT shell: **5 sekme** — Home / Members / Calendar / Earnings / Chat  
Programs sekmesi kaldırıldı; `CreateProgramScreen` üye detay Programs tab'ından açılır.

## Grup Dersler

- **Koleksiyon:** `sessions` (normal seanslarla aynı, `isGroup: true` ile ayrışır)
- **Grup ödemeler:** `payments` koleksiyonu, `isGroup: true` alanı olan belgeler
- **`ptMemberGroupPaymentsProvider`** — `pt_groups_provider.dart` içinde; `(ptId, memberId)` record key ile sorgu, `status == 'completed' && remainingSessions > 0` filtresi
- **`createGroupSession`** — `repeatWeeks` parametresi alır, `WriteBatch` ile N seans oluşturur

## Haftalık Tekrar Seans

Tüm seans oluşturma akışlarında (`GroupSessionScreen`, `_AddSessionSheet`, `_RequestSessionSheet`) tutarlı `[−][TextField][+]` stepper var, 1–52 arası, `WriteBatch` ile toplu yazma:
```dart
// SessionRepository.createSessionsBatch — pt_calendar_provider.dart
Future<void> createSessionsBatch(List<SessionModel> sessions) async {
  final batch = _firestore.batch();
  for (final session in sessions) {
    final doc = _firestore.collection(AppConstants.sessionsCollection).doc();
    batch.set(doc, session.copyWith(id: doc.id).toFirestore());
  }
  await batch.commit();
}
```

## Paket Bitti Bildirimleri (Cloud Functions)

İki tetikleyici — her ikisi de üye **ve** PT'ye eş zamanlı bildirim gönderir:

| Tetikleyici | Koşul |
|---|---|
| `paymentUpdated` (`payments/{id}`) | `isGroup: true` ödemelerde `remainingSessions` 1 veya 0'a düşünce |
| `memberProfileUpdated` (`pts/{ptId}/members/{memberId}`) | Bireysel paket `remainingSessions` 1 veya 0'a düşünce |

## Üye Detay Başlığı

`_MemberHeader` iki chip grubu gösterir:
1. Süre başına dağılım: `45dk: 5  60dk: 3` (mavi chip)
2. Aktif grup paketleri: `👥 Yoga: 8` (secondary container chip) — `ptMemberGroupPaymentsProvider` ile

## Kritik Kurallar

### Riverpod + async
`ref.read(...)` çağrılarını her zaman ilk `await`'ten ÖNCE yap — widget stream güncellemesiyle dispose olabilir:
```dart
// DOGRU
final repo = ref.read(repositoryProvider);
final memberId = session.memberId;
await repo.doSomething();

// YANLIS
await repo.doSomething();
ref.read(repositoryProvider); // widget dispose olmuş olabilir
```

### Dialog + GoRouter ShellRoute
Tüm `showDialog` çağrılarında `useRootNavigator: false` kullan, aksi halde butonlar çalışmaz:
```dart
showDialog(context: context, useRootNavigator: false, builder: ...)
```

### Firestore silme + navigasyon
Sil → başarılı → navigate et. Önce navigate etme:
```dart
await repo.deleteItem(id);
if (context.mounted) context.go(route);
```

Firestore stream ile null döndüğünde otomatik navigate için `ref.listen` kullan:
```dart
ref.listen(itemProvider(id), (prev, next) {
  if (prev?.hasValue == true && next.hasValue && next.value == null) {
    context.go(AppRoutes.somewhere);
  }
});
```

### Firestore int parsing
`as int?` yerine `(data['field'] as num?)?.toInt()` kullan (Firestore double dönebilir).

## Bildirimler (FCM)

- **Cloud Functions** seans ve ödeme olaylarında bildirim gönderir
- **iOS:** `Runner.entitlements` dosyasında `aps-environment: production` var
- **Android:** sorunsuz çalışıyor
- **iOS:** Bildirimler çalışıyor ✅

## iOS Deploy (TestFlight)

GitHub Actions workflow `workflow_dispatch` ile tetiklenir (push'ta değil):
```bash
gh workflow run "iOS TestFlight" --ref main
```

Gerekli GitHub Secrets: `BUILD_CERTIFICATE_BASE64`, `BUILD_PROVISION_PROFILE_BASE64`, `KEYCHAIN_PASSWORD`, `APPSTORE_CONNECT_API_KEY_BASE64`, `APPSTORE_CONNECT_API_KEY_ID`, `APPSTORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_APP_PASSWORD`

## Kişisel Etkinlikler

- `personal_events` Firestore koleksiyonu, `memberId` alanı sahibi tutar
- PT kişisel etkinlikleri de aynı koleksiyonda, `memberId = ptId` olarak saklanır
- Üye booking ekranı PT'nin etkinliklerini "PT meşgul" olarak gösterir
- Firestore kuralı: üye kendi PT'sinin etkinliklerini okuyabilir (`pts/{ptId}/members/{memberId}` varlığı kontrol edilir)

## Çakışma Kontrolü

Tüm overlap kontrollerinde tam aralık kullan:
```dart
bool overlaps(DateTime aStart, int aDuration, DateTime bStart, int bDuration) {
  final aEnd = aStart.add(Duration(minutes: aDuration));
  final bEnd = bStart.add(Duration(minutes: bDuration));
  return aStart.isBefore(bEnd) && aEnd.isAfter(bStart);
}
```
