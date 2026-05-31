# BookMyPT — Yapılacaklar

> Tamamlananları ~~üstü çizili~~ yapıp ✅ ile işaretle.

---

## 🔴 Store'a Çıkmadan Yapılması Gerekenler

- [ ] Android keystore ayarla — Play Store'a yüklemek için zorunlu
- [ ] iOS Info.plist: kamera, bildirim, fotoğraf izni açıklamaları ekle
- [ ] Gizlilik politikası URL'si belirle / sayfa oluştur (App Store & Play Store zorunlu kılar)
- [ ] App Store & Google Play metadata: açıklama, ekran görüntüleri, kategori
- [ ] pubspec.yaml version numarasını yönet (her release'de artır)
- [ ] iOS APNs sorunu çöz — `messaging/third-party-auth-error` (CLAUDE.md'de not var)

---

## 🟡 Orta Vadeli İyileştirmeler

- [ ] **Seans hatırlatma bildirimi** — 24 saat ve 1 saat öncesinde push; Cloud Tasks ile scheduled notification (minimal Blaze maliyeti, ~$0.01–0.10/ay); şu an sadece durum değişikliğinde bildirim gidiyor
- [ ] **Seans sonrası değerlendirme** — seans tamamlandıktan sonra üyeye "PT'yi değerlendir" prompt'u (1–5 yıldız + not); `sessions` koleksiyonuna `rating` + `ratingNote` alanı; PT profilinde ortalama göster; maliyet yok
- [ ] PT dashboard: aylık gelir grafiği, üye sayısı trendi, popüler seans saatleri; maliyet yok
- [ ] Üye: grup seans geçmişi görüntüleme (tamamlanan grup seansları listesi)
- [ ] Ödeme makbuzu: üye tamamlanan ödeme için PDF/detay ekranı görebilsin
- [ ] **Onboarding ekranı** — ilk giriş ekranı (PT ve üye için kısa walkthrough, ne yapabileceğini anlatan); maliyet yok
- [ ] PT çalışma takvimi görsel iyileştirme: üye haftalık müsait slotları görebilsin

---

## 🟢 Fikirler / Backlog

- [ ] **Grup seansı RSVP** — üye "katılacağım / katılmayacağım" önceden bildirebilsin, PT kontenjan yönetsin; maliyet yok
- [ ] Program şablonları: PT hazır şablon kaydedip farklı üyelere atayabilsin
- [ ] Multi-PT: üye birden fazla PT ile çalışabilsin
- [ ] Takvim bölümünde yapılması gereken değişiklikler tekrar değerlendirilecek

---

## ✅ Tamamlananlar

### Bu oturum (Mayıs 2026)
- ✅ PT ana menü: Dashboard → Home, Programs kaldırıldı (5 sekme)
- ✅ Üye detay başlığı: dağılımlı seans chip'leri (45dk: 5, 60dk: 3)
- ✅ Üye detay başlığı: grup paket chip'leri (👥 Yoga: 8)
- ✅ Create Program butonu üye detay Programs tabına taşındı (üye ön-seçili gelir)
- ✅ Üye alt menü: Programs + Progress kaldırıldı (4 sekme)
- ✅ Üye → PT mesaj başlatabilir (chat_list FAB)
- ✅ Quick Action butonları eşit yükseklik
- ✅ Randevu talebi sheet: SafeArea fix + min/max height
- ✅ Payment: createPayment'ta sessionDurationMinutes kaydedilmiyordu → düzeltildi
- ✅ Payment screen: eski veriden per-duration breakdown hesaplama
- ✅ Haftalık tekrar: grup seansı, PT Add Session, üye Randevu Talep Et (stepper [−][n][+])
- ✅ Cloud Functions: paket bitti → hem üyeye hem PT'ye bildirim
- ✅ Cloud Functions: son seans → hem üyeye hem PT'ye uyarı
- ✅ Group session Create Session butonu SafeArea fix

### Önceki oturumlar
- ✅ Package süre-bazlı randevu: remainingSessionsByDuration ile doğru paketten düşme
- ✅ Booking fallback: eski ödemelerden gelen sessionDurationMinutes kullanımı
- ✅ Localization: tüm hardcoded string'ler ARB'ye taşındı (TR + EN)
- ✅ help_screen.dart locale-aware yapıldı
- ✅ 55 unit test eklendi
- ✅ WorkSchedule modeli ve ekranı eklendi
- ✅ Cloud Functions: tüm bildirim olayları (seans, ödeme, davet, chat, grup)
- ✅ flutter analyze → 0 issue
