const functions = require('firebase-functions/v1');
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
    console.log('Notification sent to', token.substring(0, 20) + '...');
  } catch (e) {
    console.error('FCM send error:', e.message);
  }
}

exports.sessionCreated = functions.firestore
  .document('sessions/{sessionId}')
  .onCreate(async (snap) => {
    const session = snap.data();
    if (!session) return;

    const { ptId, memberName } = session;
    const token = await getFcmToken(ptId);
    await sendNotification(token, 'Yeni Randevu Talebi', `${memberName || 'Bir üye'} randevu talep etti`);
  });

exports.sessionUpdated = functions.firestore
  .document('sessions/{sessionId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after) return;

    if (before.status === after.status) return;

    const { memberId, ptId, memberName } = after;

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
