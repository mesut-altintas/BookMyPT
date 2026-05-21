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

// Returns all FCM tokens for a user across all their devices.
// Reads from the new fcmTokens map (ios/android keys) and also
// falls back to the legacy single fcmToken field so existing
// documents keep working until they re-login.
async function getFcmTokens(uid) {
  const data = await getUserData(uid);
  const tokens = new Set();
  if (data.fcmToken) tokens.add(data.fcmToken);
  if (data.fcmTokens && typeof data.fcmTokens === 'object') {
    Object.values(data.fcmTokens).forEach(t => { if (t) tokens.add(t); });
  }
  return [...tokens];
}

// data: { route, type } — route = GoRouter path, type = badge source key
async function sendNotification(token, title, body, data = {}) {
  if (!token) return;
  try {
    await messaging.send({
      token,
      notification: { title, body },
      data: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        ...Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])),
      },
      apns: {
        headers: { 'apns-priority': '10' },
        payload: { aps: { sound: 'default', badge: 1 } },
      },
      android: {
        priority: 'high',
        notification: { sound: 'default', channelId: 'bookmypt_default' },
      },
    });
    console.log('Notification sent to', token.substring(0, 20) + '...');
  } catch (e) {
    console.error('FCM send error:', e.message, '| code:', e.code);
  }
}

// Sends to all devices the user is logged into (iOS + Android).
async function sendToUser(uid, title, body, data = {}) {
  const tokens = await getFcmTokens(uid);
  await Promise.all(tokens.map(t => sendNotification(t, title, body, data)));
}

// ─── Payment events ───────────────────────────────────────────────────────────

exports.paymentCreated = functions.firestore
  .document('payments/{paymentId}')
  .onCreate(async (snap) => {
    const payment = snap.data();
    if (!payment) return;

    const { ptId, memberId, packageName, sessionCount, isGroup, groupName } = payment;
    const memberData = await getUserData(memberId);
    const memberName = memberData.name || memberData.displayName || 'Bir üye';

    const label = isGroup ? `"${groupName}" grubu için ` : '';
    await sendToUser(
      ptId,
      'Yeni Paket Satın Alındı',
      `${memberName} ${label}"${packageName}" paketini (${sessionCount} seans) satın aldı`,
      { route: '/pt/earnings', type: 'earnings' }
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
      await sendToUser(
        memberId,
        'Paketiniz Onaylandı',
        `"${packageName}" paketi (${sessionCount} seans) onaylandı ve hesabınıza eklendi`,
        { route: '/member/payment', type: 'payment' }
      );
    }
  });

// ─── Session events ───────────────────────────────────────────────────────────

exports.sessionCreated = functions.firestore
  .document('sessions/{sessionId}')
  .onCreate(async (snap) => {
    const session = snap.data();
    if (!session) return;

    const { ptId, memberId, memberName, isGroup, groupName } = session;
    const label = isGroup ? `"${groupName}" grubu` : (memberName || 'Bir üye');

    await sendToUser(
      ptId,
      'Yeni Randevu Talebi',
      `${label} randevu talep etti`,
      { route: '/pt/members', type: 'members' }
    );
    if (!isGroup) {
      await sendToUser(
        memberId,
        'Randevu Talebiniz Alındı',
        'Eğitmeniniz talebinizi inceleyecek',
        { route: '/member/calendar', type: 'calendar' }
      );
    }
  });

exports.sessionUpdated = functions.firestore
  .document('sessions/{sessionId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after) return;

    const { memberId, ptId, memberName, groupId } = after;

    // Cancellation request: cancellationRequestedBy changed null → 'pt'|'member'
    const prevRequested = before.cancellationRequestedBy ?? null;
    const nowRequested  = after.cancellationRequestedBy  ?? null;
    if (!prevRequested && nowRequested) {
      if (nowRequested === 'pt') {
        await sendToUser(
          memberId,
          'İptal Talebi',
          'Eğitmeniniz seansı iptal etmek istiyor',
          { route: '/member/calendar', type: 'calendar' }
        );
      } else {
        await sendToUser(
          ptId,
          'İptal Talebi',
          `${memberName || 'Üye'} seansı iptal etmek istiyor`,
          { route: '/pt/members', type: 'members' }
        );
      }
      return;
    }

    // Pending→pending: date/duration changed
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
        await sendToUser(
          ptId,
          'Randevu Talebi Güncellendi',
          `${memberName || 'Üye'} talebini ${dateStr} olarak değiştirdi`,
          { route: '/pt/members', type: 'members' }
        );
      }
      return;
    }

    if (before.status === after.status) return;

    if (after.status === 'confirmed' && before.status === 'pending') {
      await sendToUser(
        memberId,
        'Randevunuz Onaylandı',
        'Eğitmeniniz randevunuzu onayladı',
        { route: '/member/calendar', type: 'calendar' }
      );
    } else if (after.status === 'cancelled') {
      await Promise.all([
        sendToUser(memberId, 'Randevu İptal Edildi', 'Bir randevunuz iptal edildi',
          { route: '/member/calendar', type: 'calendar' }),
        sendToUser(ptId, 'Randevu İptal Edildi', `${memberName || 'Üye'} randevusunu iptal etti`,
          { route: '/pt/calendar', type: 'calendar' }),
      ]);
    } else if (after.status === 'completed') {
      await sendToUser(
        memberId,
        'Seans Tamamlandı',
        'Seansınız tamamlandı. Harika iş!',
        { route: '/member/calendar', type: 'calendar' }
      );
    }
  });

// ─── Group session events ─────────────────────────────────────────────────────

exports.groupSessionCreated = functions.firestore
  .document('group_sessions/{sessionId}')
  .onCreate(async (snap) => {
    const session = snap.data();
    if (!session) return;

    const { ptId, memberIds, groupName } = session;
    if (!Array.isArray(memberIds)) return;

    const dateObj = session.dateTime ? session.dateTime.toDate() : new Date();
    const dateStr = dateObj.toLocaleDateString('tr-TR', {
      day: 'numeric', month: 'long',
      hour: '2-digit', minute: '2-digit',
      timeZone: 'Europe/Istanbul',
    });

    await Promise.all(memberIds.map(uid =>
      sendToUser(
        uid,
        'Yeni Grup Seansı',
        `"${groupName}" grubu ${dateStr} tarihinde seans planlandı`,
        { route: '/member/calendar', type: 'calendar' }
      )
    ));
  });

exports.groupSessionUpdated = functions.firestore
  .document('group_sessions/{sessionId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;

    const { memberIds, groupName } = after;
    if (!Array.isArray(memberIds)) return;

    if (after.status === 'cancelled') {
      await Promise.all(memberIds.map(uid =>
        sendToUser(uid, 'Grup Seansı İptal', `"${groupName}" grubu seansı iptal edildi`,
          { route: '/member/calendar', type: 'calendar' })
      ));
    } else if (after.status === 'completed') {
      await Promise.all(memberIds.map(uid =>
        sendToUser(uid, 'Grup Seansı Tamamlandı', `"${groupName}" grup seansınız tamamlandı!`,
          { route: '/member/calendar', type: 'calendar' })
      ));
    }
  });

// ─── Chat message event ───────────────────────────────────────────────────────

exports.chatMessageCreated = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    if (!message) return;
    if (message.deletedForEveryone) return;

    const { chatId } = context.params;
    const chatSnap = await db.collection('chats').doc(chatId).get();
    const chat = chatSnap.data();
    if (!chat) return;

    const senderId = message.senderId;
    const text = message.text || '📷 Görsel';

    if (chat.isGroup) {
      // Group chat: notify each participant except sender with their correct route
      const participants = chat.participants || [];
      const recipients = participants.filter(uid => uid !== senderId);
      const senderData = await getUserData(senderId);
      const senderName = senderData.name || senderData.displayName || 'Biri';
      const groupName = chat.groupName || 'Grup';

      await Promise.all(recipients.map(uid => {
        const route = uid === chat.ptId
          ? `/pt/chat/${chatId}`
          : `/member/chat/${chatId}`;
        return sendToUser(
          uid,
          `${groupName}: ${senderName}`,
          text,
          { route, type: 'chat' }
        );
      }));
    } else {
      // 1:1 chat: notify the other party
      const recipientId = senderId === chat.ptId ? chat.memberId : chat.ptId;
      const isPtRecipient = recipientId === chat.ptId;
      const senderData = await getUserData(senderId);
      const senderName = senderData.name || senderData.displayName || 'Biri';

      await sendToUser(
        recipientId,
        senderName,
        text,
        {
          route: isPtRecipient ? `/pt/chat/${chatId}` : `/member/chat/${chatId}`,
          type: 'chat',
        }
      );
    }
  });
