import * as admin from "firebase-admin";
import {onDocumentCreated, onDocumentUpdated} from "firebase-functions/v2/firestore";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

function formatTime(date: Date): string {
  return `${date.getHours().toString().padStart(2, "0")}:${date.getMinutes().toString().padStart(2, "0")}`;
}

async function sendToUser(userId: string, title: string, body: string, data: Record<string, string>): Promise<void> {
  const userDoc = await db.collection("users").doc(userId).get();
  const fcmToken = userDoc.data()?.fcmToken as string | undefined;
  if (!fcmToken) return;

  await messaging.send({
    token: fcmToken,
    notification: {title, body},
    data,
    android: {priority: "high"},
    apns: {payload: {aps: {sound: "default"}}},
  });
}

// ─── Yeni rezervasyon → PT'ye bildirim ───────────────────────────────────────
export const onBookingCreated = onDocumentCreated(
  "bookings/{bookingId}",
  async (event) => {
    const booking = event.data?.data();
    if (!booking) return;

    const startTime = (booking.startTime as admin.firestore.Timestamp).toDate();

    await sendToUser(
      booking.trainerId as string,
      "Yeni Rezervasyon",
      `${booking.memberName} ${formatTime(startTime)} için rezervasyon yaptı`,
      {type: "booking_created", bookingId: event.params.bookingId}
    );
  }
);

// ─── Booking güncellendiğinde ─────────────────────────────────────────────────
export const onBookingUpdated = onDocumentUpdated(
  "bookings/{bookingId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const startTime = (after.startTime as admin.firestore.Timestamp).toDate();

    // confirmed → pending_cancel : PT'ye iptal talebi bildirimi
    if (before.status !== "pending_cancel" && after.status === "pending_cancel") {
      await sendToUser(
        after.trainerId as string,
        "İptal Talebi",
        `${after.memberName} ${formatTime(startTime)} dersini iptal etmek istiyor`,
        {type: "cancel_requested", bookingId: event.params.bookingId}
      );
    }

    // pending_cancel → cancelled : Üyeye onay bildirimi
    if (before.status === "pending_cancel" && after.status === "cancelled") {
      const memberDoc = await db.collection("members").doc(after.memberId as string).get();
      const userId = memberDoc.data()?.userId as string | undefined;
      if (!userId) return;

      await sendToUser(
        userId,
        "İptal Onaylandı",
        `${formatTime(startTime)} dersinizip talebi PT tarafından onaylandı`,
        {type: "cancel_approved", bookingId: event.params.bookingId}
      );
    }

    // pending_cancel → confirmed : Üyeye red bildirimi
    if (before.status === "pending_cancel" && after.status === "confirmed") {
      const memberDoc = await db.collection("members").doc(after.memberId as string).get();
      const userId = memberDoc.data()?.userId as string | undefined;
      if (!userId) return;

      await sendToUser(
        userId,
        "İptal Talebi Reddedildi",
        `${formatTime(startTime)} ders talebiniz PT tarafından reddedildi`,
        {type: "cancel_rejected", bookingId: event.params.bookingId}
      );
    }
  }
);
