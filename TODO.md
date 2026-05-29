# BookMyPT — Yapılacaklar

> Tamamlananları ~~üstü çizili~~ yapıp ✅ ile işaretle.

---

## 🔴 Kritik / Yakın Vadeli

- [ ] APK'yı Samsung A176B'ye yükle
- [ ] iOS TestFlight build sonucunu kontrol et
- [ ] Store Release Checklist'i tamamla

---

## 🟡 Orta Vadeli

- [ ] Android keystore ayarla (release signing için)
- [ ] iOS izin açıklamalarını Info.plist'e ekle (kamera, bildirim, vb.)
- [ ] App Store & Google Play metadata hazırla (açıklama, ekran görüntüleri)
- [ ] Gizlilik politikası sayfası oluştur / URL belirle

---

## 🟢 İyileştirmeler / Fikirler

- [ ] Takvim bölümünde yapılması gereken değişiklikler tekrar değerlendirilecek — muhtemelen değişiklik yapılacak
- [ ] (buraya yeni fikirler ekle)

---

## ✅ Tamamlananlar

- ✅ Localization: `settingsSection`, `supportSection`, `accountSection`, `workingHours` ARB'ye taşındı
- ✅ Package süre-bazlı randevu: `remainingSessionsByDuration` ile doğru paketten düşme
- ✅ `help_screen.dart` locale-aware yapıldı (TR + EN tam içerik)
- ✅ 55 unit test eklendi (member model, payment model, work schedule, duration utils)
- ✅ `scripts/test_all.ps1` oluşturuldu
- ✅ WorkSchedule modeli ve ekranı eklendi
- ✅ Admin Firestore kuralları eklendi
- ✅ Cloud Functions: program ve davet bildirimleri eklendi
- ✅ `flutter analyze` → 0 issue (46 deprecation uyarısı temizlendi)
