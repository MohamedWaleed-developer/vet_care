
const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

initializeApp({
  credential: applicationDefault(),
  projectId: "devloop-139of",
});

const ADMIN_UID = "1LIW773or1YLvGIA2tif6dUksTv2";

async function main() {
  const auth = getAuth();
  const user = await auth.getUser(ADMIN_UID);

  await auth.setCustomUserClaims(user.uid, {
    ...user.customClaims,
    admin: true,
  });

  console.log("Admin claim enabled for:", user.uid);
}

main().catch((error) => {
  console.error("Failed to enable admin claim:", error.message);
  process.exitCode = 1;
});
