
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const {
  getFirestore,
  FieldValue,
  Timestamp,
} = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { setGlobalOptions } = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");

initializeApp();

setGlobalOptions({ maxInstances: 10 });

const db = getFirestore();
const messaging = getMessaging();
const ADMIN_UID = "7sUzYjhEN3QYajAED2Fen9VYmZy2";

exports.bootstrapAdmin = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must sign in first.");
  }

  if (request.auth.uid !== ADMIN_UID) {
    throw new HttpsError(
      "permission-denied",
      "You are not allowed to perform this action.",
    );
  }

  const auth = getAuth();
  const user = await auth.getUser(request.auth.uid);

  await auth.setCustomUserClaims(user.uid, {
    ...user.customClaims,
    admin: true,
  });

  return {
    success: true,
    message: "Admin privileges enabled.",
  };
});

async function requireAdmin(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }

  if (request.auth.token.admin !== true) {
    throw new HttpsError("permission-denied", "Admin access is required.");
  }
}

async function getActiveTokens(userId) {
  const snapshot = await db
    .collection("users")
    .doc(userId)
    .collection("devices")
    .where("isActive", "==", true)
    .get();

  return [
    ...new Set(
      snapshot.docs
        .map((doc) => doc.data().token)
        .filter((token) => typeof token === "string" && token.length > 0),
    ),
  ];
}

async function sendPushToTokens(tokens, title, body, data = {}) {
  let successCount = 0;
  let failureCount = 0;

  for (let i = 0; i < tokens.length; i += 500) {
    const chunk = tokens.slice(i, i + 500);

    const response = await messaging.sendEachForMulticast({
      tokens: chunk,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([key, value]) => [key, String(value)]),
      ),
      android: {
        priority: "high",
        notification: { sound: "default" },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
        },
      },
    });

    successCount += response.successCount;
    failureCount += response.failureCount;
  }

  return { successCount, failureCount };
}

async function createUserNotification({
  notificationId,
  userId,
  title,
  body,
  type,
  relatedId = null,
  data = {},
}) {
  const ref = notificationId
    ? db.collection("notifications").doc(notificationId)
    : db.collection("notifications").doc();

  const created = await db.runTransaction(async (transaction) => {
    const existing = await transaction.get(ref);

    if (existing.exists) return false;

    transaction.create(ref, {
      userId,
      title,
      body,
      type,
      relatedId,
      data,
      isRead: false,
      createdAt: FieldValue.serverTimestamp(),
    });

    return true;
  });

  if (!created) return false;

  try {
    const tokens = await getActiveTokens(userId);

    if (tokens.length > 0) {
      await sendPushToTokens(tokens, title, body, {
        type,
        notificationId: ref.id,
        ...(relatedId ? { relatedId } : {}),
        ...data,
      });
    }
  } catch (error) {
    console.error("Push delivery failed:", ref.id, error);
  }

  return true;
}

exports.sendCustomerBroadcast = onCall(
  { timeoutSeconds: 540, memory: "1GiB" },
  async (request) => {
    await requireAdmin(request);

    const title = typeof request.data?.title === "string"
      ? request.data.title.trim()
      : "";
    const body = typeof request.data?.body === "string"
      ? request.data.body.trim()
      : "";
    const type = request.data?.type;
    const destination = request.data?.destination;

    if (!title || title.length > 80 || !body || body.length > 300) {
      throw new HttpsError(
        "invalid-argument",
        "A title and body within the allowed lengths are required.",
      );
    }

    if (!["announcement", "offer", "product", "category"].includes(type)) {
      throw new HttpsError("invalid-argument", "Invalid notification type.");
    }

    if (!["home", "store", "notifications"].includes(destination)) {
      throw new HttpsError("invalid-argument", "Invalid destination.");
    }

    let lastDocument = null;
    let recipientCount = 0;
    let notificationCount = 0;
    let pushSuccessCount = 0;

    while (true) {
      let query = db.collection("users").orderBy("__name__").limit(200);

      if (lastDocument) query = query.startAfter(lastDocument);

      const users = await query.get();
      if (users.empty) break;

      for (const user of users.docs) {
        recipientCount++;

        const created = await createUserNotification({
          userId: user.id,
          title,
          body,
          type,
          data: { destination },
        });

        if (created) notificationCount++;

        try {
          const tokens = await getActiveTokens(user.id);

          if (tokens.length > 0) {
            const result = await sendPushToTokens(tokens, title, body, {
              type,
              destination,
            });

            pushSuccessCount += result.successCount;
          }
        } catch (error) {
          console.error("Broadcast push failed for user:", user.id, error);
        }
      }

      lastDocument = users.docs[users.docs.length - 1];
      if (users.size < 200) break;
    }

    return {
      success: true,
      recipientCount,
      notificationCount,
      pushSuccessCount,
    };
  },
);

exports.notifyOrderStatusChanged = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after || before.status === after.status) return;

    const userId = after.userId;
    const orderId = event.params.orderId;

    if (typeof userId !== "string" || !userId) {
      console.error("Order has no valid userId:", orderId);
      return;
    }

    const labels = {
      confirmed: "تم تأكيد طلبك",
      preparing: "طلبك قيد التجهيز",
      shipping: "طلبك خرج للشحن",
      delivered: "تم تسليم طلبك",
      cancelled: "تم إلغاء طلبك",
    };

    const title = labels[after.status];
    if (!title) return;

    const eventTime = after.updatedAt?.toMillis?.() ?? event.time;
    const safeTime = String(eventTime).replace(/[^a-zA-Z0-9_-]/g, "_");

    await createUserNotification({
      notificationId: `order_${orderId}_${after.status}_${safeTime}`,
      userId,
      title,
      body: `تم تحديث حالة الطلب رقم ${after.orderNumber || orderId}.`,
      type: "order_update",
      relatedId: orderId,
      data: { orderId, status: after.status },
    });
  },
);

exports.sendVaccinationReminders = onSchedule(
  {
    schedule: "every day 09:00",
    timeZone: "Asia/Riyadh",
    timeoutSeconds: 540,
    memory: "1GiB",
  },
  async () => {
    const now = new Date();
    const today = new Date(
      Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
    );

    const offsets = [0, 3];
    let remindersCreated = 0;

    for (const offset of offsets) {
      const targetDate = new Date(today);
      targetDate.setUTCDate(targetDate.getUTCDate() + offset);

      const start = Timestamp.fromDate(targetDate);
      const endDate = new Date(targetDate);
      endDate.setUTCDate(endDate.getUTCDate() + 1);

      const vaccinations = await db
        .collection("vaccinations")
        .where("dueDate", ">=", start)
        .where("dueDate", "<", Timestamp.fromDate(endDate))
        .get();

      for (const vaccination of vaccinations.docs) {
        const vaccine = vaccination.data();

        if (typeof vaccine.petId !== "string" || !vaccine.petId) continue;

        const petDoc = await db.collection("pets").doc(vaccine.petId).get();
        if (!petDoc.exists) continue;

        const ownerId = petDoc.data()?.ownerId;
        if (typeof ownerId !== "string" || !ownerId) continue;

        const dateKey = targetDate.toISOString().slice(0, 10);
        const notificationId =
          `vaccination_${vaccination.id}_${offset}_${dateKey}`;

        const title = offset === 0
          ? "موعد التطعيم اليوم"
          : "تذكير بموعد التطعيم";

        const vaccineName = vaccine.vaccineName || "التطعيم";
        const body = offset === 0
          ? `موعد ${vaccineName} مستحق اليوم.`
          : `متبقي 3 أيام على موعد ${vaccineName}.`;

        const created = await createUserNotification({
          notificationId,
          userId: ownerId,
          title,
          body,
          type: "vaccination_reminder",
          relatedId: vaccine.petId,
          data: {
            petId: vaccine.petId,
            vaccinationId: vaccination.id,
          },
        });

        if (created) remindersCreated++;
      }
    }

    console.log("Vaccination reminders created:", remindersCreated);
  },
);
