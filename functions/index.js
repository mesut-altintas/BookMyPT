const functions = require('firebase-functions/v1');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

async function getUserData(uid) {
  const snap = await db.collection('users').doc(uid).get();
  return snap.data() ?? {};
}

async function getFcmToken(uid) {
  const data = await getUserData(uid);
  return data.fcmToken ?? null;
}

async function sendNotification(token, title, body) {
  if (!token) return;
  try {
    await messaging.send({ token, notification: { title, body } });
    console.log('Notification sent to', token.substring(0, 20) + '...');
  } catch (e) {
    console.error('FCM send error:', e.message, '| code:', e.code, '| token prefix:', token.substring(0, 15));
  }
}

exports.paymentCreated = functions.firestore
  .document('payments/{paymentId}')
  .onCreate(async (snap) => {
    const payment = snap.data();
    if (!payment) return;

    const { ptId, memberId, packageName, sessionCount } = payment;
    const memberData = await getUserData(memberId);
    const memberName = memberData.name || memberData.displayName || 'Bir üye';

    const ptToken = await getFcmToken(ptId);
    await sendNotification(
      ptToken,
      'Yeni Paket Satın Alındı',
      `${memberName} "${packageName}" paketini (${sessionCount} seans) satın aldı`
    );
  });

exports.paymentUpdated = functions.firestore
  .document('payments/{paymentId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;

    const { memberId, packageName, sessionCount } = after;

    if (after.status === 'completed' && before.status === 'pending') {
      const memberToken = await getFcmToken(memberId);
      await sendNotification(
        memberToken,
        'Paketiniz Onaylandı',
        `"${packageName}" paketi (${sessionCount} seans) onaylandı ve hesabınıza eklendi`
      );
    }
  });

exports.sessionCreated = functions.firestore
  .document('sessions/{sessionId}')
  .onCreate(async (snap) => {
    const session = snap.data();
    if (!session) return;

    const { ptId, memberId, memberName } = session;
    const [ptToken, memberToken] = await Promise.all([getFcmToken(ptId), getFcmToken(memberId)]);
    await sendNotification(ptToken, 'Yeni Randevu Talebi', `${memberName || 'Bir üye'} randevu talep etti`);
    await sendNotification(memberToken, 'Randevu Talebiniz Alındı', 'Eğitmeniniz talebinizi inceleyecek');
  });

exports.sessionUpdated = functions.firestore
  .document('sessions/{sessionId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after) return;

    const { memberId, ptId, memberName } = after;

    // Member updated their pending request (date/time or duration changed)
    if (before.status === 'pending' && after.status === 'pending') {
      const beforeMs = before.dateTime ? before.dateTime.toMillis() : 0;
      const afterMs  = after.dateTime  ? after.dateTime.toMillis()  : 0;
      const dateChanged     = beforeMs !== afterMs;
      const durationChanged = before.durationMinutes !== after.durationMinutes;
      if (dateChanged || durationChanged) {
        const dateObj = after.dateTime.toDate();
        const dateStr = dateObj.toLocaleDateString('tr-TR', {
          day: 'numeric', month: 'long',
          hour: '2-digit', minute: '2-digit',
          timeZone: 'Europe/Istanbul',
        });
        const ptToken = await getFcmToken(ptId);
        await sendNotification(
          ptToken,
          'Randevu Talebi Güncellendi',
          `${memberName || 'Üye'} talebini ${dateStr} olarak değiştirdi`
        );
      }
      return;
    }

    if (before.status === after.status) return;

    if (after.status === 'confirmed' && before.status === 'pending') {
      const token = await getFcmToken(memberId);
      await sendNotification(token, 'Randevunuz Onaylandı', 'Eğitmeniniz randevunuzu onayladı');
    } else if (after.status === 'cancelled') {
      const memberToken = await getFcmToken(memberId);
      const ptToken = await getFcmToken(ptId);
      await sendNotification(memberToken, 'Randevu İptal Edildi', 'Bir randevunuz iptal edildi');
      await sendNotification(ptToken, 'Randevu İptal Edildi', `${memberName || 'Üye'} randevusunu iptal etti`);
    } else if (after.status === 'completed') {
      const token = await getFcmToken(memberId);
      await sendNotification(token, 'Seans Tamamlandı', 'Seansınız tamamlandı. Harika iş!');
    }
  });
