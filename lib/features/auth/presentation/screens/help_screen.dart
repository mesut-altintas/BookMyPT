import 'package:flutter/material.dart';

import '../../../../core/l10n/extensions.dart';

class HelpScreen extends StatelessWidget {
  final bool isPt;
  const HelpScreen({super.key, required this.isPt});

  bool _isTr(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'tr';

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

  List<Widget> _memberSections(BuildContext context) {
    final tr = _isTr(context);
    final sections = tr ? _memberDataTr() : _memberDataEn();
    final intro = tr ? _memberIntroTr() : _memberIntroEn();
    final tip   = tr
        ? 'İpucu: Randevu talebi göndermeden önce PT\'nizin çalışma saatlerini kontrol edin. Takvimde gri görünen günler PT\'nin kapalı günleridir.'
        : 'Tip: Check your PT\'s working hours before submitting an appointment request. Days shown in grey on the calendar are your PT\'s days off.';
    return [
      _intro(context, icon: Icons.waving_hand_outlined,
          title: intro.$1, body: intro.$2),
      for (final s in sections)
        _sectionWidget(context, s),
      _tipBox(context, tip),
      const SizedBox(height: 24),
    ];
  }

  // ── PT ──────────────────────────────────────────────────────────────────────

  List<Widget> _ptSections(BuildContext context) {
    final tr = _isTr(context);
    final sections = tr ? _ptDataTr() : _ptDataEn();
    final intro = tr ? _ptIntroTr() : _ptIntroEn();
    final tip   = tr
        ? 'İpucu: Çalışma saatlerinizi ayarladıktan sonra üyeleriniz yalnızca müsait olduğunuz zaman dilimlerinde randevu talep edebilir. Bu sayede takvim yönetimi çok daha kolay hale gelir.'
        : 'Tip: After setting your working hours, members can only request appointments during your available time slots. This makes calendar management much easier.';
    return [
      _intro(context, icon: Icons.waving_hand_outlined,
          title: intro.$1, body: intro.$2),
      for (final s in sections)
        _sectionWidget(context, s),
      _tipBox(context, tip),
      const SizedBox(height: 24),
    ];
  }

  // ── INTRO DATA ───────────────────────────────────────────────────────────────

  (String, String) _memberIntroTr() => (
    'BookMyPT\'ye Hoş Geldiniz!',
    'Bu kılavuz, uygulamanın tüm özelliklerini en iyi şekilde kullanmanıza yardımcı olacak. Aşağıdaki bölümlere tıklayarak detaylı bilgiye ulaşabilirsiniz.',
  );

  (String, String) _memberIntroEn() => (
    'Welcome to BookMyPT!',
    'This guide will help you get the most out of all the app\'s features. Tap any section below to learn more.',
  );

  (String, String) _ptIntroTr() => (
    'BookMyPT\'ye Hoş Geldiniz!',
    'Bu kılavuz, üyelerinizi yönetmek, takvimi düzenlemek ve tüm PT araçlarını verimli kullanmanıza yardımcı olacak. Bölümlere tıklayarak detaylara ulaşabilirsiniz.',
  );

  (String, String) _ptIntroEn() => (
    'Welcome to BookMyPT!',
    'This guide will help you manage your members, organize your schedule, and use all PT tools efficiently. Tap sections to access details.',
  );

  // ── MEMBER DATA ──────────────────────────────────────────────────────────────

  List<_HelpSection> _memberDataTr() => [
    _HelpSection(
      icon: Icons.home_outlined, title: 'Ana Sayfa', color: Colors.indigo,
      items: const [
        _HelpItem('Genel Bakış', 'Ana sayfada yaklaşan randevularınız, eğitmeninizin bilgileri, son ilerleme kaydınız ve kalan seans sayınız görünür.'),
        _HelpItem('Eğitmen Bilgisi', 'Atanmış eğitmeniniz varsa adı ve fotoğrafı gösterilir. Henüz bir PT\'niz yoksa "PT Bul" butonuyla arama yapabilirsiniz.'),
        _HelpItem('Hızlı Randevu', '"Randevu Al" butonuyla doğrudan randevu talep ekranına geçebilirsiniz.'),
      ],
    ),
    _HelpSection(
      icon: Icons.calendar_today_outlined, title: 'Randevularım', color: Colors.teal,
      items: const [
        _HelpItem('Randevu Talebi', 'Sağ üstteki + butonuna veya boş gün kutucuğuna tıklayarak randevu talep edebilirsiniz. PT\'nizin çalışma saatleri dışındaki günler takvimde gri olarak görünür ve seçilemez.'),
        _HelpItem('Çalışma Saatleri Kısıtlaması', 'PT\'niz çalışma saatlerini belirlediyse bu saatler dışında randevu talebinde bulunamazsınız. Geçersiz bir saat seçildiğinde hata mesajı görünür ve "Gönder" butonu pasif kalır.'),
        _HelpItem('Randevu Düzenleme', '"Bekliyor" statüsündeki randevularınızın üzerine tıklayarak saat veya süresini değiştirebilirsiniz. Onaylanmış randevuları sadece iptal talebi göndererek değiştirebilirsiniz.'),
        _HelpItem('İptal Talebi', 'Onaylanmış bir randevuyu iptal etmek için randevu detayından "İptal Talebi Gönder" butonunu kullanın. PT onayladığında randevu iptal edilir.'),
        _HelpItem('Geçmiş Seanslar', '"Geçmişim" sekmesinde tamamlanan seanslarınızı ve toplam antrenman sürenizi görebilirsiniz.'),
      ],
    ),
    _HelpSection(
      icon: Icons.event_note_outlined, title: 'Takvimim', color: Colors.purple,
      items: const [
        _HelpItem('Kişisel Etkinlikler', 'Kendi takviminize antrenman, aktivite gibi kişisel etkinlikler ekleyebilirsiniz. Bu etkinlikler sadece size görünür.'),
        _HelpItem('Davetler', 'PT\'nizden veya grup seanslarından gelen davetleri bu ekranda yönetebilirsiniz.'),
        _HelpItem('Zaman Çakışması', 'Randevu talep ederken mevcut etkinliklerinizle çakışma varsa sistem sizi uyarır.'),
      ],
    ),
    _HelpSection(
      icon: Icons.inventory_2_outlined, title: 'Paketler & Ödemeler', color: Colors.orange,
      items: const [
        _HelpItem('Paket Satın Alma', 'PT\'nizin sunduğu paketleri görüntüleyebilir ve satın alabilirsiniz. Satın alım sonrası PT onayladığında seanslar hesabınıza eklenir.'),
        _HelpItem('Kalan Seanslar', 'Her seansın tamamlanmasıyla kalan seans sayınız 1 azalır. Ana sayfada ve profil bölümünde güncel sayıyı görebilirsiniz.'),
        _HelpItem('Ödeme Geçmişi', '"Geçmiş" sekmesinde tüm ödeme işlemlerinizi ve paket durumlarını görebilirsiniz.'),
        _HelpItem('Pasif Üyelik', 'Seanslarınız bittiğinde üyeliğiniz pasife alınabilir. Yeniden aktif olmak için PT\'nize aktivasyon talebi gönderebilirsiniz.'),
      ],
    ),
    _HelpSection(
      icon: Icons.fitness_center_outlined, title: 'Programlarım', color: Colors.deepPurple,
      items: const [
        _HelpItem('Program Görüntüleme', 'PT\'nizin size atadığı antrenman programlarını bu bölümde görebilirsiniz. Bildirim alarak yeni program atandığında haberdar olursunuz.'),
        _HelpItem('Antrenman Detayı', 'Programa tıklayarak haftalık planı, egzersizleri, set/tekrar sayılarını ve notları inceleyebilirsiniz.'),
      ],
    ),
    _HelpSection(
      icon: Icons.show_chart_outlined, title: 'İlerlemem', color: Colors.green,
      items: const [
        _HelpItem('Ölçüm Ekleme', 'Kilo, vücut yağ oranı, kas kitlesi gibi ölçümlerinizi düzenli olarak kaydedebilirsiniz.'),
        _HelpItem('Grafik Takibi', 'Kaydettiğiniz ölçümler grafik halinde gösterilir; zaman içindeki değişiminizi kolayca takip edebilirsiniz.'),
        _HelpItem('PT Erişimi', 'PT\'niz ilerleme kayıtlarınızı görebilir ve programınızı buna göre güncelleyebilir.'),
      ],
    ),
    _HelpSection(
      icon: Icons.chat_bubble_outline, title: 'Mesajlar', color: Colors.blue,
      items: const [
        _HelpItem('PT ile Mesajlaşma', 'PT\'nizle doğrudan mesajlaşabilirsiniz. Mesaj geldiğinde bildirim alırsınız.'),
        _HelpItem('Grup Sohbeti', 'Grup seansı olan üyeler, grup sohbetine katılabilir ve diğer üyelerle iletişim kurabilir.'),
        _HelpItem('Medya Paylaşımı', 'Sohbet ekranında fotoğraf paylaşabilirsiniz.'),
      ],
    ),
    _HelpSection(
      icon: Icons.notifications_outlined, title: 'Bildirimler', color: Colors.red,
      items: const [
        _HelpItem('Hangi Durumlarda Bildirim Gelir?', 'Randevunuz onaylandığında veya reddedildiğinde, yeni program atandığında, ödemeniz onaylandığında, davet aldığınızda ve mesaj geldiğinde bildirim alırsınız.'),
        _HelpItem('Bildirim İzinleri', 'Bildirimlerin çalışması için uygulama izni gereklidir. Profil → Ayarlar → Bildirimler bölümünden izin durumunu kontrol edebilirsiniz.'),
      ],
    ),
  ];

  List<_HelpSection> _memberDataEn() => [
    _HelpSection(
      icon: Icons.home_outlined, title: 'Home', color: Colors.indigo,
      items: const [
        _HelpItem('Overview', 'The home screen shows your upcoming appointments, trainer info, latest progress entry, and remaining session count.'),
        _HelpItem('Trainer Info', 'If you have an assigned trainer, their name and photo are displayed. If you don\'t have a PT yet, tap "Find PT" to search.'),
        _HelpItem('Quick Booking', 'Tap "Book Session" to go directly to the appointment request screen.'),
      ],
    ),
    _HelpSection(
      icon: Icons.calendar_today_outlined, title: 'My Appointments', color: Colors.teal,
      items: const [
        _HelpItem('Appointment Request', 'Tap the + button in the top right or tap an empty day to request an appointment. Days outside your PT\'s working hours appear grey and cannot be selected.'),
        _HelpItem('Working Hours Restriction', 'If your PT has set working hours, you cannot request appointments outside those hours. An error message appears and the Send button is disabled when an invalid time is selected.'),
        _HelpItem('Edit Appointment', 'Tap a Pending appointment to change its time or duration. Approved appointments can only be changed by sending a cancellation request.'),
        _HelpItem('Cancellation Request', 'To cancel an approved appointment, use the "Send Cancellation Request" button in the appointment detail. The appointment is cancelled when the PT approves.'),
        _HelpItem('Past Sessions', 'In the History tab, you can view your completed sessions and total training time.'),
      ],
    ),
    _HelpSection(
      icon: Icons.event_note_outlined, title: 'My Calendar', color: Colors.purple,
      items: const [
        _HelpItem('Personal Events', 'You can add personal events like workouts or activities to your calendar. These events are only visible to you.'),
        _HelpItem('Invitations', 'Manage invitations from your PT or group sessions on this screen.'),
        _HelpItem('Time Conflicts', 'The system warns you if there\'s a conflict with existing events when requesting an appointment.'),
      ],
    ),
    _HelpSection(
      icon: Icons.inventory_2_outlined, title: 'Packages & Payments', color: Colors.orange,
      items: const [
        _HelpItem('Package Purchase', 'View and purchase packages offered by your PT. Sessions are added to your account when the PT approves the payment.'),
        _HelpItem('Remaining Sessions', 'Your remaining session count decreases by 1 with each completed session. You can see the current count on the home screen and in the profile section.'),
        _HelpItem('Payment History', 'View all your payment transactions and package statuses in the History tab.'),
        _HelpItem('Inactive Membership', 'When your sessions run out, your membership may be deactivated. Send an activation request to your PT to become active again.'),
      ],
    ),
    _HelpSection(
      icon: Icons.fitness_center_outlined, title: 'My Programs', color: Colors.deepPurple,
      items: const [
        _HelpItem('View Programs', 'Training programs assigned to you by your PT are shown here. You\'ll receive a notification when a new program is assigned.'),
        _HelpItem('Workout Details', 'Tap a program to see the weekly plan, exercises, sets/reps, and notes.'),
      ],
    ),
    _HelpSection(
      icon: Icons.show_chart_outlined, title: 'My Progress', color: Colors.green,
      items: const [
        _HelpItem('Add Measurements', 'Regularly record measurements like weight, body fat percentage, and muscle mass.'),
        _HelpItem('Chart Tracking', 'Recorded measurements are shown as charts; easily track changes over time.'),
        _HelpItem('PT Access', 'Your PT can view your progress records and update your program accordingly.'),
      ],
    ),
    _HelpSection(
      icon: Icons.chat_bubble_outline, title: 'Messages', color: Colors.blue,
      items: const [
        _HelpItem('Message PT', 'You can message your PT directly. You\'ll receive a notification when a message arrives.'),
        _HelpItem('Group Chat', 'Members with group sessions can join the group chat and communicate with other members.'),
        _HelpItem('Media Sharing', 'You can share photos in the chat screen.'),
      ],
    ),
    _HelpSection(
      icon: Icons.notifications_outlined, title: 'Notifications', color: Colors.red,
      items: const [
        _HelpItem('When Do I Get Notifications?', 'You\'ll receive notifications when your appointment is approved or rejected, a new program is assigned, your payment is approved, you receive an invitation, and when a message arrives.'),
        _HelpItem('Notification Permissions', 'App permission is required for notifications to work. Check permission status at Profile → Settings → Notifications.'),
      ],
    ),
  ];

  // ── PT DATA ──────────────────────────────────────────────────────────────────

  List<_HelpSection> _ptDataTr() => [
    _HelpSection(
      icon: Icons.home_outlined, title: 'Ana Sayfa', color: Colors.indigo,
      items: const [
        _HelpItem('Genel Bakış', 'Ana sayfada bugünkü ve yaklaşan seanslarınız, toplam üye sayınız ve bu haftaki seans özeti görünür.'),
        _HelpItem('Bekleyen Talepler', 'Üyelerden gelen bekleyen randevu talepleri ana sayfada öne çıkarılır. Hızlıca onaylayabilir veya takvime geçebilirsiniz.'),
        _HelpItem('Son Üyeler', 'En son eklenen veya aktif olan üyeleriniz listede görünür. Üyeye tıklayarak detay ekranına geçebilirsiniz.'),
      ],
    ),
    _HelpSection(
      icon: Icons.calendar_today_outlined, title: 'Takvim', color: Colors.teal,
      items: const [
        _HelpItem('Seans Yönetimi', 'Takvimde bir güne tıklayarak o günün seanslarını görün. Bekleyen randevu taleplerine tıklayarak onaylayabilir veya iptal edebilirsiniz.'),
        _HelpItem('Seans Ekleme', '+ butonuyla takvime manuel seans ekleyebilirsiniz. Üye seçin, tarih/saat ve süre belirleyin.'),
        _HelpItem('Seans Detayı', 'Seansa tıklayınca "Bekliyor" statüsünde ise Onayla/İptal Et butonları, "Onaylandı" statüsünde ise Tamamlandı ve İptal Talebi seçenekleri görünür.'),
        _HelpItem('Kişisel Etkinlikler', 'İzin, toplantı gibi kişisel etkinliklerinizi takvime ekleyebilirsiniz. Bu süreler boyunca üyeler randevu talebinde bulunamaz.'),
      ],
    ),
    _HelpSection(
      icon: Icons.people_outline, title: 'Üyeler', color: Colors.purple,
      items: const [
        _HelpItem('Üye Ekleme', 'Davet göndererek veya direkt ekleyerek yeni üye alabilirsiniz. Üye e-postasını girerek davet gönderdiğinizde üyeye bildirim gider.'),
        _HelpItem('Üye Detayı — Seanslar', 'Üye detay ekranındaki "Seanslar" sekmesinde o üyeye ait tüm seanslar listelenir. "Bekliyor" statüsündeki seansa tıklayarak doğrudan onaylayabilir veya iptal edebilirsiniz.'),
        _HelpItem('Aktif / Pasif Yönetimi', 'Sağ üst menüden üyeyi pasife alabilirsiniz. Pasif üyeler randevu talebi gönderemez; aktivasyon talebi göndererek yeniden aktif olmak isteyebilirler.'),
        _HelpItem('Gruplar', 'Birden fazla üyeyi grup seansına dahil edebilirsiniz. Grup seansı oluşturulduğunda tüm üyelere bildirim gider.'),
      ],
    ),
    _HelpSection(
      icon: Icons.fitness_center_outlined, title: 'Programlar', color: Colors.deepPurple,
      items: const [
        _HelpItem('Program Oluşturma', 'Üyeye özel haftalık antrenman programları oluşturabilirsiniz. Program oluşturulduğunda üyeye otomatik bildirim gönderilir.'),
        _HelpItem('Egzersiz Detayı', 'Her egzersiz için set, tekrar, ağırlık ve not ekleyebilirsiniz.'),
        _HelpItem('Program Güncelleme', 'Mevcut programı düzenleyebilir veya pasife alabilirsiniz. Pasif programlar üyeye gösterilmez.'),
      ],
    ),
    _HelpSection(
      icon: Icons.inventory_2_outlined, title: 'Paketler', color: Colors.orange,
      items: const [
        _HelpItem('Paket Tanımlama', 'Gelir → Paket Yönetimi bölümünden üyelere sunacağınız paketleri oluşturun: ad, seans sayısı ve fiyat girin.'),
        _HelpItem('Satın Alım Onayı', 'Üye paket satın aldığında size bildirim gelir. Ödemeyi Gelir ekranından onayladığınızda seanslar üyenin hesabına eklenir.'),
        _HelpItem('Grup Paketleri', 'Grup seansları için ayrı paket tanımlayabilirsiniz.'),
        _HelpItem('Kalan Seans Takibi', 'Her tamamlanan seansta üyenin kalan seans sayısı 1 azalır. Sıfırlandığında üyelik otomatik pasife geçer.'),
      ],
    ),
    _HelpSection(
      icon: Icons.payments_outlined, title: 'Gelir', color: Colors.green,
      items: const [
        _HelpItem('Gelir Takibi', 'Tüm onaylanmış ödemeleri, toplam aylık ve yıllık geliri bu ekranda görebilirsiniz.'),
        _HelpItem('Bekleyen Ödemeler', 'Üye paket satın aldıktan sonra ödeme "Bekliyor" statüsünde görünür. Onayladığınızda "Tamamlandı" olur ve seanslar eklenir.'),
        _HelpItem('Grafik & Özet', 'Aylık gelir grafiğiyle kazancınızın trendi takip edebilirsiniz.'),
      ],
    ),
    _HelpSection(
      icon: Icons.schedule_outlined, title: 'Çalışma Saatleri', color: Colors.brown,
      items: const [
        _HelpItem('Çalışma Günleri Ayarı', 'Profil → Çalışma Saatleri bölümünden hangi günler çalıştığınızı ve saatlerinizi belirleyebilirsiniz. Kapalı günlerinizde üyeler randevu talebinde bulunamaz.'),
        _HelpItem('Hızlı Uygula', '"Hızlı Uygula" bölümünde günleri seçip tek seferde hepsine aynı saatleri uygulayabilirsiniz. Sonradan her günü ayrı ayrı düzenleyebilirsiniz.'),
        _HelpItem('Mola Saati', 'Her gün için opsiyonel bir mola aralığı tanımlayabilirsiniz. Mola saatlerinde üyeler randevu talebinde bulunamaz.'),
        _HelpItem('Takvimde Görünüm', 'Üye randevu talep ederken takvimde çalışmadığınız günler gri ve seçilemez olarak gösterilir.'),
      ],
    ),
    _HelpSection(
      icon: Icons.chat_bubble_outline, title: 'Mesajlar', color: Colors.blue,
      items: const [
        _HelpItem('Bireysel Mesajlaşma', 'Üye detay ekranındaki mesaj ikonuyla veya Mesajlar sekmesinden üyeyle sohbet başlatabilirsiniz.'),
        _HelpItem('Grup Sohbeti', 'Grup seansı olan üyeler için otomatik grup sohbeti oluşturulur.'),
        _HelpItem('Bildirimler', 'Yeni mesaj geldiğinde anlık bildirim alırsınız. Mesaja tıklayınca doğrudan ilgili sohbete yönlendirilirsiniz.'),
      ],
    ),
    _HelpSection(
      icon: Icons.notifications_outlined, title: 'Bildirimler', color: Colors.red,
      items: const [
        _HelpItem('Hangi Durumlarda Bildirim Gelir?', 'Yeni üyelik isteği, aktivasyon talebi, davet kabulü/reddi, paket satın alımı, randevu talebi, seans iptal talebi ve yeni mesaj geldiğinde bildirim alırsınız.'),
        _HelpItem('Birden Fazla Cihaz', 'Hem iOS hem Android cihazınıza giriş yaparsanız her iki cihaza da bildirim gönderilir. Farklı hesapla giriş yapıldığında önceki cihaz bildirim almaz.'),
        _HelpItem('Bildirim İzinleri', 'Bildirimlerin çalışması için uygulama izni gereklidir. Profil → Ayarlar → Bildirimler bölümünden izin durumunu kontrol edebilirsiniz.'),
      ],
    ),
  ];

  List<_HelpSection> _ptDataEn() => [
    _HelpSection(
      icon: Icons.home_outlined, title: 'Home', color: Colors.indigo,
      items: const [
        _HelpItem('Overview', 'The home screen shows today\'s and upcoming sessions, your total member count, and this week\'s session summary.'),
        _HelpItem('Pending Requests', 'Pending appointment requests from members are highlighted on the home screen. Approve quickly or navigate to the calendar.'),
        _HelpItem('Recent Members', 'Your most recently added or active members appear in the list. Tap a member to go to their detail screen.'),
      ],
    ),
    _HelpSection(
      icon: Icons.calendar_today_outlined, title: 'Calendar', color: Colors.teal,
      items: const [
        _HelpItem('Session Management', 'Tap a day in the calendar to see that day\'s sessions. Tap pending requests to approve or cancel them.'),
        _HelpItem('Add Session', 'Use the + button to manually add a session to the calendar. Select a member, set the date/time and duration.'),
        _HelpItem('Session Detail', 'When you tap a session: Pending status shows Approve/Cancel buttons; Approved status shows Completed and Cancellation options.'),
        _HelpItem('Personal Events', 'Add personal events like time off or meetings to your calendar. Members cannot request appointments during these periods.'),
      ],
    ),
    _HelpSection(
      icon: Icons.people_outline, title: 'Members', color: Colors.purple,
      items: const [
        _HelpItem('Add Member', 'Add new members by sending an invitation or adding directly. When you invite a member by email, they receive a notification.'),
        _HelpItem('Member Detail — Sessions', 'The Sessions tab on the member detail screen lists all sessions for that member. Tap a Pending session to approve or cancel it directly.'),
        _HelpItem('Active / Inactive Management', 'Deactivate a member from the top-right menu. Inactive members cannot request appointments; they can send an activation request to become active again.'),
        _HelpItem('Groups', 'You can include multiple members in a group session. All members are notified when a group session is created.'),
      ],
    ),
    _HelpSection(
      icon: Icons.fitness_center_outlined, title: 'Programs', color: Colors.deepPurple,
      items: const [
        _HelpItem('Create Program', 'Create customized weekly training programs for each member. A notification is automatically sent to the member when a program is created.'),
        _HelpItem('Exercise Details', 'Add sets, reps, weight, and notes for each exercise.'),
        _HelpItem('Update Program', 'Edit an existing program or deactivate it. Inactive programs are not shown to the member.'),
      ],
    ),
    _HelpSection(
      icon: Icons.inventory_2_outlined, title: 'Packages', color: Colors.orange,
      items: const [
        _HelpItem('Define Package', 'From Earnings → Package Management, create the packages you offer to members: enter name, session count, and price.'),
        _HelpItem('Purchase Approval', 'You\'ll receive a notification when a member purchases a package. When you approve the payment from the Earnings screen, sessions are added to the member\'s account.'),
        _HelpItem('Group Packages', 'Define separate packages for group sessions.'),
        _HelpItem('Remaining Session Tracking', 'With each completed session, the member\'s remaining session count decreases by 1. When it reaches zero, the membership automatically becomes inactive.'),
      ],
    ),
    _HelpSection(
      icon: Icons.payments_outlined, title: 'Earnings', color: Colors.green,
      items: const [
        _HelpItem('Earnings Tracking', 'View all approved payments, total monthly and annual income on this screen.'),
        _HelpItem('Pending Payments', 'After a member purchases a package, the payment appears as Pending. When you approve it, it becomes Completed and sessions are added.'),
        _HelpItem('Chart & Summary', 'Track the trend of your earnings with the monthly income chart.'),
      ],
    ),
    _HelpSection(
      icon: Icons.schedule_outlined, title: 'Working Hours', color: Colors.brown,
      items: const [
        _HelpItem('Set Working Days', 'From Profile → Working Hours, set which days you work and your hours. Members cannot request appointments on your closed days.'),
        _HelpItem('Quick Apply', 'In the Quick Apply section, select days and apply the same hours to all of them at once. You can then edit each day individually.'),
        _HelpItem('Break Time', 'Define an optional break period for each day. Members cannot request appointments during break times.'),
        _HelpItem('Calendar View', 'When a member requests an appointment, non-working days are shown in grey and cannot be selected in the calendar.'),
      ],
    ),
    _HelpSection(
      icon: Icons.chat_bubble_outline, title: 'Messages', color: Colors.blue,
      items: const [
        _HelpItem('Individual Messaging', 'Start a chat with a member from the message icon on the member detail screen or from the Messages tab.'),
        _HelpItem('Group Chat', 'A group chat is automatically created for members with group sessions.'),
        _HelpItem('Notifications', 'You\'ll receive an instant notification when a new message arrives. Tapping it takes you directly to the relevant chat.'),
      ],
    ),
    _HelpSection(
      icon: Icons.notifications_outlined, title: 'Notifications', color: Colors.red,
      items: const [
        _HelpItem('When Do I Get Notifications?', 'You\'ll receive notifications for: new membership requests, activation requests, invitation acceptance/rejection, package purchases, appointment requests, session cancellation requests, and new messages.'),
        _HelpItem('Multiple Devices', 'If you log in on both iOS and Android devices, notifications are sent to both. When logging in with a different account, the previous device no longer receives notifications.'),
        _HelpItem('Notification Permissions', 'App permission is required for notifications to work. Check permission status at Profile → Settings → Notifications.'),
      ],
    ),
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
              Icon(icon, size: 28, color: theme.colorScheme.onPrimaryContainer),
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

  Widget _sectionWidget(BuildContext context, _HelpSection section) {
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
              color: section.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(section.icon, color: section.color, size: 20),
          ),
          title: Text(section.title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: section.items
              .map((item) => _buildItem(context, item, section.color))
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

// ── Data classes ──────────────────────────────────────────────────────────────

class _HelpSection {
  final IconData icon;
  final String title;
  final Color color;
  final List<_HelpItem> items;

  const _HelpSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
  });
}

class _HelpItem {
  final String title;
  final String body;
  const _HelpItem(this.title, this.body);
}
