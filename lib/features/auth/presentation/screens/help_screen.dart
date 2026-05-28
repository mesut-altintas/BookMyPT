import 'package:flutter/material.dart';

import '../../../../core/l10n/extensions.dart';

class HelpScreen extends StatelessWidget {
  final bool isPt;
  const HelpScreen({super.key, required this.isPt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.helpGuideTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: isPt ? _ptSections(context) : _memberSections(context),
      ),
    );
  }

  // ── MEMBER ──────────────────────────────────────────────────────────────────

  List<Widget> _memberSections(BuildContext context) => [
        _intro(
          context,
          icon: Icons.waving_hand_outlined,
          title: 'BookMyPT\'ye Hoş Geldiniz!',
          body:
              'Bu kılavuz, uygulamanın tüm özelliklerini en iyi şekilde kullanmanıza yardımcı olacak. Aşağıdaki bölümlere tıklayarak detaylı bilgiye ulaşabilirsiniz.',
        ),
        _section(
          context,
          icon: Icons.home_outlined,
          title: 'Ana Sayfa',
          color: Colors.indigo,
          items: const [
            _HelpItem(
              title: 'Genel Bakış',
              body: 'Ana sayfada yaklaşan randevularınız, eğitmeninizin bilgileri, son ilerleme kaydınız ve kalan seans sayınız görünür.',
            ),
            _HelpItem(
              title: 'Eğitmen Bilgisi',
              body: 'Atanmış eğitmeniniz varsa adı ve fotoğrafı gösterilir. Henüz bir PT\'niz yoksa "PT Bul" butonuyla arama yapabilirsiniz.',
            ),
            _HelpItem(
              title: 'Hızlı Randevu',
              body: '"Randevu Al" butonuyla doğrudan randevu talep ekranına geçebilirsiniz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.calendar_today_outlined,
          title: 'Randevularım',
          color: Colors.teal,
          items: const [
            _HelpItem(
              title: 'Randevu Talebi',
              body: 'Sağ üstteki + butonuna veya boş gün kutucuğuna tıklayarak randevu talep edebilirsiniz. PT\'nizin çalışma saatleri dışındaki günler takvimde gri olarak görünür ve seçilemez.',
            ),
            _HelpItem(
              title: 'Çalışma Saatleri Kısıtlaması',
              body: 'PT\'niz çalışma saatlerini belirlediyse bu saatler dışında randevu talebinde bulunamazsınız. Geçersiz bir saat seçildiğinde hata mesajı görünür ve "Gönder" butonu pasif kalır.',
            ),
            _HelpItem(
              title: 'Randevu Düzenleme',
              body: '"Bekliyor" statüsündeki randevularınızın üzerine tıklayarak saat veya süresini değiştirebilirsiniz. Onaylanmış randevuları sadece iptal talebi göndererek değiştirebilirsiniz.',
            ),
            _HelpItem(
              title: 'İptal Talebi',
              body: 'Onaylanmış bir randevuyu iptal etmek için randevu detayından "İptal Talebi Gönder" butonunu kullanın. PT onayladığında randevu iptal edilir.',
            ),
            _HelpItem(
              title: 'Geçmiş Seanslar',
              body: '"Geçmişim" sekmesinde tamamlanan seanslarınızı ve toplam antrenman sürenizi görebilirsiniz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.event_note_outlined,
          title: 'Takvimim',
          color: Colors.purple,
          items: const [
            _HelpItem(
              title: 'Kişisel Etkinlikler',
              body: 'Kendi takviminize antrenman, aktivite gibi kişisel etkinlikler ekleyebilirsiniz. Bu etkinlikler sadece size görünür.',
            ),
            _HelpItem(
              title: 'Davetler',
              body: 'PT\'nizden veya grup seanslarından gelen davetleri bu ekranda yönetebilirsiniz.',
            ),
            _HelpItem(
              title: 'Zaman Çakışması',
              body: 'Randevu talep ederken mevcut etkinliklerinizle çakışma varsa sistem sizi uyarır.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.inventory_2_outlined,
          title: 'Paketler & Ödemeler',
          color: Colors.orange,
          items: const [
            _HelpItem(
              title: 'Paket Satın Alma',
              body: 'PT\'nizin sunduğu paketleri görüntüleyebilir ve satın alabilirsiniz. Satın alım sonrası PT onayladığında seanslar hesabınıza eklenir.',
            ),
            _HelpItem(
              title: 'Kalan Seanslar',
              body: 'Her seansın tamamlanmasıyla kalan seans sayınız 1 azalır. Ana sayfada ve profil bölümünde güncel sayıyı görebilirsiniz.',
            ),
            _HelpItem(
              title: 'Ödeme Geçmişi',
              body: '"Geçmiş" sekmesinde tüm ödeme işlemlerinizi ve paket durumlarını görebilirsiniz.',
            ),
            _HelpItem(
              title: 'Pasif Üyelik',
              body: 'Seanslarınız bittiğinde üyeliğiniz pasife alınabilir. Yeniden aktif olmak için PT\'nize aktivasyon talebi gönderebilirsiniz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.fitness_center_outlined,
          title: 'Programlarım',
          color: Colors.deepPurple,
          items: const [
            _HelpItem(
              title: 'Program Görüntüleme',
              body: 'PT\'nizin size atadığı antrenman programlarını bu bölümde görebilirsiniz. Bildirim alarak yeni program atandığında haberdar olursunuz.',
            ),
            _HelpItem(
              title: 'Antrenman Detayı',
              body: 'Programa tıklayarak haftalık planı, egzersizleri, set/tekrar sayılarını ve notları inceleyebilirsiniz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.show_chart_outlined,
          title: 'İlerlemem',
          color: Colors.green,
          items: const [
            _HelpItem(
              title: 'Ölçüm Ekleme',
              body: 'Kilo, vücut yağ oranı, kas kitlesi gibi ölçümlerinizi düzenli olarak kaydedebilirsiniz.',
            ),
            _HelpItem(
              title: 'Grafik Takibi',
              body: 'Kaydettiğiniz ölçümler grafik halinde gösterilir; zaman içindeki değişiminizi kolayca takip edebilirsiniz.',
            ),
            _HelpItem(
              title: 'PT Erişimi',
              body: 'PT\'niz ilerleme kayıtlarınızı görebilir ve programınızı buna göre güncelleyebilir.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.chat_bubble_outline,
          title: 'Mesajlar',
          color: Colors.blue,
          items: const [
            _HelpItem(
              title: 'PT ile Mesajlaşma',
              body: 'PT\'nizle doğrudan mesajlaşabilirsiniz. Mesaj geldiğinde bildirim alırsınız.',
            ),
            _HelpItem(
              title: 'Grup Sohbeti',
              body: 'Grup seansı olan üyeler, grup sohbetine katılabilir ve diğer üyelerle iletişim kurabilir.',
            ),
            _HelpItem(
              title: 'Medya Paylaşımı',
              body: 'Sohbet ekranında fotoğraf paylaşabilirsiniz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.notifications_outlined,
          title: 'Bildirimler',
          color: Colors.red,
          items: const [
            _HelpItem(
              title: 'Hangi Durumlarda Bildirim Gelir?',
              body: 'Randevunuz onaylandığında veya reddedildiğinde, yeni program atandığında, ödemeniz onaylandığında, davet aldığınızda ve mesaj geldiğinde bildirim alırsınız.',
            ),
            _HelpItem(
              title: 'Bildirim İzinleri',
              body: 'Bildirimlerin çalışması için uygulama izni gereklidir. Profil → Ayarlar → Bildirimler bölümünden izin durumunu kontrol edebilirsiniz.',
            ),
          ],
        ),
        _tipBox(context,
            'İpucu: Randevu talebi göndermeden önce PT\'nizin çalışma saatlerini kontrol edin. Takvimde gri görünen günler PT\'nin kapalı günleridir.'),
        const SizedBox(height: 24),
      ];

  // ── PT ──────────────────────────────────────────────────────────────────────

  List<Widget> _ptSections(BuildContext context) => [
        _intro(
          context,
          icon: Icons.waving_hand_outlined,
          title: 'BookMyPT\'ye Hoş Geldiniz!',
          body:
              'Bu kılavuz, üyelerinizi yönetmek, takvimi düzenlemek ve tüm PT araçlarını verimli kullanmanıza yardımcı olacak. Bölümlere tıklayarak detaylara ulaşabilirsiniz.',
        ),
        _section(
          context,
          icon: Icons.home_outlined,
          title: 'Ana Sayfa',
          color: Colors.indigo,
          items: const [
            _HelpItem(
              title: 'Genel Bakış',
              body: 'Ana sayfada bugünkü ve yaklaşan seanslarınız, toplam üye sayınız ve bu haftaki seans özeti görünür.',
            ),
            _HelpItem(
              title: 'Bekleyen Talepler',
              body: 'Üyelerden gelen bekleyen randevu talepleri ana sayfada öne çıkarılır. Hızlıca onaylayabilir veya takvime geçebilirsiniz.',
            ),
            _HelpItem(
              title: 'Son Üyeler',
              body: 'En son eklenen veya aktif olan üyeleriniz listede görünür. Üyeye tıklayarak detay ekranına geçebilirsiniz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.calendar_today_outlined,
          title: 'Takvim',
          color: Colors.teal,
          items: const [
            _HelpItem(
              title: 'Seans Yönetimi',
              body: 'Takvimde bir güne tıklayarak o günün seanslarını görün. Bekleyen randevu taleplerine tıklayarak onaylayabilir veya iptal edebilirsiniz.',
            ),
            _HelpItem(
              title: 'Seans Ekleme',
              body: '+ butonuyla takvime manuel seans ekleyebilirsiniz. Üye seçin, tarih/saat ve süre belirleyin.',
            ),
            _HelpItem(
              title: 'Seans Detayı',
              body: 'Seansa tıklayınca "Bekliyor" statüsünde ise Onayla/İptal Et butonları, "Onaylandı" statüsünde ise Tamamlandı ve İptal Talebi seçenekleri görünür.',
            ),
            _HelpItem(
              title: 'Kişisel Etkinlikler',
              body: 'İzin, toplantı gibi kişisel etkinliklerinizi takvime ekleyebilirsiniz. Bu süreler boyunca üyeler randevu talebinde bulunamaz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.people_outline,
          title: 'Üyeler',
          color: Colors.purple,
          items: const [
            _HelpItem(
              title: 'Üye Ekleme',
              body: 'Davet göndererek veya direkt ekleyerek yeni üye alabilirsiniz. Üye e-postasını girerek davet gönderdiğinizde üyeye bildirim gider.',
            ),
            _HelpItem(
              title: 'Üye Detayı — Seanslar',
              body: 'Üye detay ekranındaki "Seanslar" sekmesinde o üyeye ait tüm seanslar listelenir. "Bekliyor" statüsündeki seansa tıklayarak doğrudan onaylayabilir veya iptal edebilirsiniz.',
            ),
            _HelpItem(
              title: 'Aktif / Pasif Yönetimi',
              body: 'Sağ üst menüden üyeyi pasife alabilirsiniz. Pasif üyeler randevu talebi gönderemez; aktivasyon talebi göndererek yeniden aktif olmak isteyebilirler.',
            ),
            _HelpItem(
              title: 'Gruplar',
              body: 'Birden fazla üyeyi grup seansına dahil edebilirsiniz. Grup seansı oluşturulduğunda tüm üyelere bildirim gider.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.fitness_center_outlined,
          title: 'Programlar',
          color: Colors.deepPurple,
          items: const [
            _HelpItem(
              title: 'Program Oluşturma',
              body: 'Üyeye özel haftalık antrenman programları oluşturabilirsiniz. Program oluşturulduğunda üyeye otomatik bildirim gönderilir.',
            ),
            _HelpItem(
              title: 'Egzersiz Detayı',
              body: 'Her egzersiz için set, tekrar, ağırlık ve not ekleyebilirsiniz.',
            ),
            _HelpItem(
              title: 'Program Güncelleme',
              body: 'Mevcut programı düzenleyebilir veya pasife alabilirsiniz. Pasif programlar üyeye gösterilmez.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.inventory_2_outlined,
          title: 'Paketler',
          color: Colors.orange,
          items: const [
            _HelpItem(
              title: 'Paket Tanımlama',
              body: 'Gelir → Paket Yönetimi bölümünden üyelere sunacağınız paketleri oluşturun: ad, seans sayısı ve fiyat girin.',
            ),
            _HelpItem(
              title: 'Satın Alım Onayı',
              body: 'Üye paket satın aldığında size bildirim gelir. Ödemeyi Gelir ekranından onayladığınızda seanslar üyenin hesabına eklenir.',
            ),
            _HelpItem(
              title: 'Grup Paketleri',
              body: 'Grup seansları için ayrı paket tanımlayabilirsiniz.',
            ),
            _HelpItem(
              title: 'Kalan Seans Takibi',
              body: 'Her tamamlanan seansta üyenin kalan seans sayısı 1 azalır. Sıfırlandığında üyelik otomatik pasife geçer.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.payments_outlined,
          title: 'Gelir',
          color: Colors.green,
          items: const [
            _HelpItem(
              title: 'Gelir Takibi',
              body: 'Tüm onaylanmış ödemeleri, toplam aylık ve yıllık geliri bu ekranda görebilirsiniz.',
            ),
            _HelpItem(
              title: 'Bekleyen Ödemeler',
              body: 'Üye paket satın aldıktan sonra ödeme "Bekliyor" statüsünde görünür. Onayladığınızda "Tamamlandı" olur ve seanslar eklenir.',
            ),
            _HelpItem(
              title: 'Grafik & Özet',
              body: 'Aylık gelir grafiğiyle kazancınızın trendi takip edebilirsiniz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.schedule_outlined,
          title: 'Çalışma Saatleri',
          color: Colors.brown,
          items: const [
            _HelpItem(
              title: 'Çalışma Günleri Ayarı',
              body: 'Profil → Çalışma Saatleri bölümünden hangi günler çalıştığınızı ve saatlerinizi belirleyebilirsiniz. Kapalı günlerinizde üyeler randevu talebinde bulunamaz.',
            ),
            _HelpItem(
              title: 'Hızlı Uygula',
              body: '"Hızlı Uygula" bölümünde günleri seçip tek seferde hepsine aynı saatleri uygulayabilirsiniz. Sonradan her günü ayrı ayrı düzenleyebilirsiniz.',
            ),
            _HelpItem(
              title: 'Mola Saati',
              body: 'Her gün için opsiyonel bir mola aralığı tanımlayabilirsiniz. Mola saatlerinde üyeler randevu talebinde bulunamaz.',
            ),
            _HelpItem(
              title: 'Takvimde Görünüm',
              body: 'Üye randevu talep ederken takvimde çalışmadığınız günler gri ve seçilemez olarak gösterilir.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.chat_bubble_outline,
          title: 'Mesajlar',
          color: Colors.blue,
          items: const [
            _HelpItem(
              title: 'Bireysel Mesajlaşma',
              body: 'Üye detay ekranındaki mesaj ikonuyla veya Mesajlar sekmesinden üyeyle sohbet başlatabilirsiniz.',
            ),
            _HelpItem(
              title: 'Grup Sohbeti',
              body: 'Grup seansı olan üyeler için otomatik grup sohbeti oluşturulur.',
            ),
            _HelpItem(
              title: 'Bildirimler',
              body: 'Yeni mesaj geldiğinde anlık bildirim alırsınız. Mesaja tıklayınca doğrudan ilgili sohbete yönlendirilirsiniz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.notifications_outlined,
          title: 'Bildirimler',
          color: Colors.red,
          items: const [
            _HelpItem(
              title: 'Hangi Durumlarda Bildirim Gelir?',
              body: 'Yeni üyelik isteği, aktivasyon talebi, davet kabulü/reddi, paket satın alımı, randevu talebi, seans iptal talebi ve yeni mesaj geldiğinde bildirim alırsınız.',
            ),
            _HelpItem(
              title: 'Birden Fazla Cihaz',
              body: 'Hem iOS hem Android cihazınıza giriş yaparsanız her iki cihaza da bildirim gönderilir. Farklı hesapla giriş yapıldığında önceki cihaz bildirim almaz.',
            ),
            _HelpItem(
              title: 'Bildirim İzinleri',
              body: 'Bildirimlerin çalışması için uygulama izni gereklidir. Profil → Ayarlar → Bildirimler bölümünden izin durumunu kontrol edebilirsiniz.',
            ),
          ],
        ),
        _tipBox(context,
            'İpucu: Çalışma saatlerinizi ayarladıktan sonra üyeleriniz yalnızca müsait olduğunuz zaman dilimlerinde randevu talep edebilir. Bu sayede takvim yönetimi çok daha kolay hale gelir.'),
        const SizedBox(height: 24),
      ];

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _intro(BuildContext context,
      {required IconData icon,
      required String title,
      required String body}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 28, color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        )),
                    const SizedBox(height: 6),
                    Text(body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.85),
                          height: 1.5,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required List<_HelpItem> items,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children:
              items.map((item) => _buildItem(context, item, color)).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _HelpItem item, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(item.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipBox(BuildContext context, String tip) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(tip,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpItem {
  final String title;
  final String body;
  const _HelpItem({required this.title, required this.body});
}
