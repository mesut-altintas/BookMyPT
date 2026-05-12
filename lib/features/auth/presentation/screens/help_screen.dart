import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  final bool isPt;
  const HelpScreen({super.key, required this.isPt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanım Kılavuzu')),
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
          title: 'BookMyPT\'e Hoş Geldiniz!',
          body:
              'Bu uygulama sayesinde eğitmeninizle kolayca randevu alabilir, '
              'ilerlemenizi takip edebilir ve seans paketlerinizi yönetebilirsiniz.',
        ),
        _section(
          context,
          icon: Icons.home_outlined,
          title: 'Ana Ekran',
          color: Colors.indigo,
          items: const [
            _HelpItem(
              title: 'Eğitmen Bilgileri',
              body:
                  'Atanmış PT\'niz, kalan seans hakkınız ve yaklaşan randevularınız '
                  'ana ekranda bir bakışta görünür.',
            ),
            _HelpItem(
              title: 'PT Atanmamışsa',
              body:
                  '"PT Bul" özelliği üzerinden e-posta adresiyle eğitmeninizi '
                  'sisteme ekleyebilirsiniz. PT sizi sisteme aldıktan sonra '
                  'randevu ve paket işlemleri aktif olur.',
            ),
            _HelpItem(
              title: 'Üyeliği Bırak',
              body:
                  'PT kartındaki "Üyeliği Bırak" butonuyla eğitmeninizle '
                  'bağlantınızı kesebilirsiniz. Kalan seans haklarınız '
                  'bu işlemden etkilenmez.',
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
              title: 'Randevu Talebi Oluşturma',
              body:
                  'Sağ üstteki + butonuna basın, tarih ve saati seçin. '
                  'Paketinizde seans süresi tanımlıysa otomatik belirlenir. '
                  'Talebiniz PT onayına gönderilir.',
            ),
            _HelpItem(
              title: 'Takvim Sekmesi',
              body:
                  'Günlük bazda tüm randevularınızı görürsünüz. '
                  'Mavi nokta kendi randevularınızı, gri nokta PT\'nin meşgul '
                  'olduğu saatleri gösterir. Bekleyen taleplerinize tıklayarak '
                  'tarih veya saati değiştirebilirsiniz.',
            ),
            _HelpItem(
              title: 'Geçmişim Sekmesi',
              body:
                  'Tamamlanan seanslarınızın sayısı ve toplam süresini burada '
                  'görürsünüz. Yaklaşan onaylı randevularınız da bu sekmede '
                  'listelenir.',
            ),
            _HelpItem(
              title: 'Randevu Durumları',
              body:
                  '• Bekliyor: Talep oluşturuldu, PT onayı bekleniyor.\n'
                  '• Onaylandı: PT kabul etti, seans gerçekleşecek.\n'
                  '• Tamamlandı: Seans gerçekleşti.\n'
                  '• İptal: Seans iptal edildi.',
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
              title: 'Kişisel Etkinlik Ekleme',
              body:
                  'Sağ üstteki + butonuyla kişisel etkinlikler ekleyebilirsiniz '
                  '(antrenman, toplantı, tatil vb.). Bu etkinlikler yalnızca '
                  'sizin takviminizde görünür.',
            ),
            _HelpItem(
              title: 'PT\'nin Müsaitliği',
              body:
                  'PT\'nizin başka üyelerle olan randevuları ve kişisel etkinlikleri '
                  'gri renkte görünür. Böylece randevu talebinde bulunmadan önce '
                  'müsaitliği kontrol edebilirsiniz.',
            ),
            _HelpItem(
              title: 'Etkinlik Düzenleme',
              body:
                  'Eklediğiniz kişisel etkinliklere tıklayarak tarih, saat, '
                  'süre ve notlarını düzenleyebilir ya da silebilirsiniz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.inventory_2_outlined,
          title: 'Paketlerim',
          color: Colors.orange,
          items: const [
            _HelpItem(
              title: 'Paket Satın Alma',
              body:
                  'PT\'nizin sunduğu seans paketlerini bu ekranda görürsünüz. '
                  '"Satın Al" butonuna bastığınızda ödeme talebi oluşur; '
                  'PT onayladıktan sonra seans hakkınız hesabınıza eklenir.',
            ),
            _HelpItem(
              title: 'Üyeye Özel Paketler',
              body:
                  'PT\'niz sizin için özel fiyatlı veya süreli paket '
                  'oluşturmuş olabilir. Bu paketleri yalnızca siz görebilirsiniz.',
            ),
            _HelpItem(
              title: 'Ödeme Geçmişi',
              body:
                  'Tüm ödeme talepleriniz ve durumları (Bekliyor / Tamamlandı) '
                  'ekranın üst kısmında listelenir.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.show_chart_outlined,
          title: 'İlerleme',
          color: Colors.green,
          items: const [
            _HelpItem(
              title: 'Ölçüm Girişi',
              body:
                  'Kilo, boy ve vücut ölçülerinizi kaydedebilirsiniz. '
                  'Fotoğraf ekleyerek görsel ilerlemenizi de takip edebilirsiniz.',
            ),
            _HelpItem(
              title: 'Geçmişe Dönük Giriş',
              body:
                  'Girişi unuttuğunuz günler için tarih seçerek geçmişe dönük '
                  'kayıt yapabilirsiniz.',
            ),
            _HelpItem(
              title: 'Grafik Takibi',
              body:
                  'Kaydettiğiniz ölçümler grafik olarak gösterilir. '
                  'Zaman içindeki değişiminizi kolayca izleyebilirsiniz.',
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
              title: 'PT ile İletişim',
              body:
                  'PT\'nizle doğrudan mesajlaşabilirsiniz. '
                  'Seans değişiklikleri, sorular veya antrenman notları için '
                  'bu ekranı kullanın.',
            ),
          ],
        ),
        _tipBox(context),
        const SizedBox(height: 24),
      ];

  // ── PT ──────────────────────────────────────────────────────────────────────

  List<Widget> _ptSections(BuildContext context) => [
        _intro(
          context,
          icon: Icons.waving_hand_outlined,
          title: 'BookMyPT\'e Hoş Geldiniz!',
          body:
              'Bu uygulama sayesinde üyelerinizin randevularını kolayca yönetebilir, '
              'seans paketleri oluşturabilir ve kazançlarınızı takip edebilirsiniz.',
        ),
        _section(
          context,
          icon: Icons.home_outlined,
          title: 'Ana Ekran',
          color: Colors.indigo,
          items: const [
            _HelpItem(
              title: 'Günlük Özet',
              body:
                  'Bugünkü randevularınız, bekleyen talepler ve son üye '
                  'hareketleri ana ekranda listelenir.',
            ),
            _HelpItem(
              title: 'Bekleyen Talepler',
              body:
                  'Üyelerinizin randevu taleplerini buradan hızlıca onaylayabilir '
                  'veya reddedebilirsiniz. Onay verdiğinizde üyeye bildirim gider.',
            ),
            _HelpItem(
              title: 'Aktivasyon İstekleri',
              body:
                  'Pasif üyeler aktivasyon isteği gönderebilir. '
                  'Bu istekleri ana ekrandan yönetebilirsiniz.',
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
              title: 'Randevu Yönetimi',
              body:
                  'Tüm üyelerinizin seansları takvimde renkli noktalarla görünür. '
                  'Bir güne tıklayarak o günkü detaylı listeye geçebilirsiniz.',
            ),
            _HelpItem(
              title: 'Kişisel Etkinlik',
              body:
                  'Sağ üstteki + butonu ile tatil, toplantı gibi kişisel '
                  'etkinlikler ekleyebilirsiniz. Bu saatler üyelerin randevu '
                  'takviminde "meşgul" olarak görünür.',
            ),
            _HelpItem(
              title: 'Seans Detayı',
              body:
                  'Listedeki bir seansa tıklayarak detay ekranını açabilir, '
                  'durumu güncelleyebilir (onayla / iptal / tamamla) ve '
                  'notlar ekleyebilirsiniz.',
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
              body:
                  'Yeni üye eklemek için + butonuna basın ve üyenin bilgilerini '
                  'girin. Sisteme eklenen üye size bağlanır ve randevu alabilir.',
            ),
            _HelpItem(
              title: 'Üye Yönetimi',
              body:
                  'Üye kartına tıklayarak profil detayını görüntüleyebilir, '
                  'kişisel hedef ve notlar ekleyebilir, kalan seans haklarını '
                  'takip edebilirsiniz.',
            ),
            _HelpItem(
              title: 'Aktif / Pasif Durumu',
              body:
                  'Üyeyi pasife aldığınızda o üye yeni randevu talebi '
                  'oluşturamaz. Aktivasyon isteği gönderirse siz onaylarsınız.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.inventory_2_outlined,
          title: 'Paket Yönetimi',
          color: Colors.orange,
          items: const [
            _HelpItem(
              title: 'Paket Oluşturma',
              body:
                  'Seans sayısı, süresi ve fiyatını belirleyerek paket '
                  'oluşturabilirsiniz. Paketler tüm aktif üyelerinize görünür.',
            ),
            _HelpItem(
              title: 'Üyeye Özel Paket',
              body:
                  '"Üyeye özel" seçeneğiyle belirli bir üye için özel '
                  'fiyatlı paket tanımlayabilirsiniz. Bu paket yalnızca '
                  'o üyenin Paketlerim ekranında görünür.',
            ),
            _HelpItem(
              title: 'Seans Süresi',
              body:
                  'Pakette seans süresi belirtirseniz, o üye randevu '
                  'alırken süre otomatik olarak belirlenir ve üye '
                  'manuel seçim yapamaz.',
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.payments_outlined,
          title: 'Kazançlar & Ödemeler',
          color: Colors.green,
          items: const [
            _HelpItem(
              title: 'Ödeme Onaylama',
              body:
                  'Üye paket satın aldığında ödeme talebi oluşur. '
                  'Siz onayladığınızda üyenin seans hakkı otomatik olarak '
                  'güncellenir ve üyeye bildirim gider.',
            ),
            _HelpItem(
              title: 'Ödeme Reddetme',
              body:
                  'Ödemenin gerçekleşmediği durumlarda talebi reddedebilirsiniz. '
                  'Seans hakkı eklenmez.',
            ),
            _HelpItem(
              title: 'Kazanç Özeti',
              body:
                  'Aylık ve toplam kazanç özeti ekranın üst kısmında görünür.',
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
              title: 'Üye İletişimi',
              body:
                  'Tüm üyelerinizle ayrı ayrı mesajlaşabilirsiniz. '
                  'Antrenman notları, diyet önerileri veya seans '
                  'değişiklikleri için kullanın.',
            ),
          ],
        ),
        _tipBox(context),
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
          children: items
              .map((item) => _buildItem(context, item, color))
              .toList(),
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
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

  Widget _tipBox(BuildContext context) {
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
            const Icon(Icons.lightbulb_outline,
                color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sorun yaşarsanız uygulamayı kapatıp yeniden açmayı deneyin. '
                'Bildirim almak için Profil → Bildirimler bölümünden '
                'bildirim izinlerini kontrol edin.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
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
