const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { setGlobalOptions } = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");

initializeApp();

setGlobalOptions({ maxInstances: 10 });

const ADMIN_UID = "7sUzYjhEN3QYajAED2Fen9VYmZy2";

exports.bootstrapAdmin = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must sign in first."
    );
  }

  if (request.auth.uid !== ADMIN_UID) {
    throw new HttpsError(
      "permission-denied",
      "You are not allowed to perform this action."
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