const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

async function getFcmToken(uid) {
  const snap = await db.collection('users').doc(uid).get();
  return snap.data()?.fcmToken ?? null;
}

async function sendNotification(token, title, body) {
  if (!token) return;
  try {
    await messaging.send({ token, notification: { title, body } });
  } catch (e) {
    console.error('FCM send error:', e.message);
  }
}

// Yeni seans oluşturulduğunda PT'ye bildirim gönder
exports.onSessionCreated = onDocumentCreated('sessions/{sessionId}', async (event) => {
  const session = event.data?.data();
  if (!session) return;

  const { ptId, memberName } = session;
  const token = await getFcmToken(ptId);
  await sendNotification(token, 'Yeni Randevu Talebi', `${memberName || 'Bir üye'} randevu talep etti`);
});

// Seans durumu değiştiğinde ilgili tarafı bilgilendir
exports.onSessionUpdated = onDocumentUpdated('sessions/{sessionId}', async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) return;

  const statusChanged = before.status !== after.status;
  if (!statusChanged) return;

  const { memberId, ptId, memberName } = after;

  if (after.status === 'confirmed' && before.status === 'pending') {
    // Üyeye: randevu onaylandı
    const token = await getFcmToken(memberId);
    await sendNotification(token, 'Randevunuz Onaylandı', 'Eğitmeniniz randevunuzu onayladı');
  } else if (after.status === 'cancelled') {
    // Kim iptal etti belli değil, ikisini de bilgilendir
    const memberToken = await getFcmToken(memberId);
    const ptToken = await getFcmToken(ptId);
    await sendNotification(memberToken, 'Randevu İptal Edildi', 'Bir randevunuz iptal edildi');
    await sendNotification(ptToken, 'Randevu İptal Edildi', `${memberName || 'Üye'} randevusunu iptal etti`);
  } else if (after.status === 'completed') {
    const token = await getFcmToken(memberId);
    await sendNotification(token, 'Seans Tamamlandı', 'Seansınız tamamlandı. Harika iş!');
  }
});
