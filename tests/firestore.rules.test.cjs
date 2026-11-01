
const fs = require("node:fs");
const path = require("node:path");
const {
  before,
  after,
  afterEach,
  describe,
  it,
} = require("node:test");

const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");

const {
  doc,
  getDoc,
  setDoc,
  collection,
  getDocs,
} = require("firebase/firestore");

const PROJECT_ID = "demo-vet-care";

let testEnv;

before(async () => {
  const rules = fs.readFileSync(
    path.resolve(__dirname, "../firestore.rules"),
    "utf8",
  );

  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules },
  });
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

function userDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function adminDb() {
  return testEnv.authenticatedContext("admin-user", {
    admin: true,
  }).firestore();
}

function unauthenticatedDb() {
  return testEnv.unauthenticatedContext().firestore();
}

describe("Vet Care Firestore security rules", () => {
  it("blocks unauthenticated reads of private user profiles", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "users/user-a"), {
        uid: "user-a",
        name: "Customer A",
      });
    });

    await assertFails(
      getDoc(doc(unauthenticatedDb(), "users/user-a")),
    );
  });

  it("allows a user to read their own profile", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "users/user-a"), {
        uid: "user-a",
        name: "Customer A",
      });
    });

    await assertSucceeds(
      getDoc(doc(userDb("user-a"), "users/user-a")),
    );
  });

  it("blocks a user from reading another user's profile", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "users/user-b"), {
        uid: "user-b",
        name: "Customer B",
      });
    });

    await assertFails(
      getDoc(doc(userDb("user-a"), "users/user-b")),
    );
  });

  it("allows a user to create their own profile", async () => {
    await assertSucceeds(
      setDoc(doc(userDb("user-a"), "users/user-a"), {
        uid: "user-a",
        name: "Customer A",
        phoneNumber: "0500000000",
      }),
    );
  });

  it("blocks a user from creating a profile with an admin role", async () => {
    await assertFails(
      setDoc(doc(userDb("user-a"), "users/user-a"), {
        uid: "user-a",
        name: "Customer A",
        role: "admin",
      }),
    );
  });

  it("blocks users from updating their profile uid", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "users/user-a"), {
        uid: "user-a",
        name: "Customer A",
      });
    });

    await assertFails(
      setDoc(
        doc(userDb("user-a"), "users/user-a"),
        { uid: "user-b" },
        { merge: true },
      ),
    );
  });

  it("blocks users from adding unapproved profile fields", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "users/user-a"), {
        uid: "user-a",
        name: "Customer A",
      });
    });

    await assertFails(
      setDoc(
        doc(userDb("user-a"), "users/user-a"),
        { role: "admin" },
        { merge: true },
      ),
    );
  });

  it("allows a user to create their own pet", async () => {
    await assertSucceeds(
      setDoc(doc(userDb("user-a"), "pets/pet-a"), {
        ownerId: "user-a",
        name: "Cat",
        category: "cat",
      }),
    );
  });

  it("blocks a user from creating a pet for another user", async () => {
    await assertFails(
      setDoc(doc(userDb("user-a"), "pets/pet-b"), {
        ownerId: "user-b",
        name: "Cat",
        category: "cat",
      }),
    );
  });

  it("blocks a user from reading another user's pet", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "pets/pet-b"), {
        ownerId: "user-b",
        name: "Cat",
        category: "cat",
      });
    });

    await assertFails(
      getDoc(doc(userDb("user-a"), "pets/pet-b")),
    );
  });

  it("allows a pet owner to create a vaccination", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "pets/pet-a"), {
        ownerId: "user-a",
        name: "Cat",
        category: "cat",
      });
    });

    await assertSucceeds(
      setDoc(doc(userDb("user-a"), "vaccinations/vaccine-a"), {
        petId: "pet-a",
        vaccineName: "Rabies",
        dueDate: new Date(),
      }),
    );
  });

  it("blocks a user from creating a vaccination for another user's pet", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "pets/pet-b"), {
        ownerId: "user-b",
        name: "Cat",
        category: "cat",
      });
    });

    await assertFails(
      setDoc(doc(userDb("user-a"), "vaccinations/vaccine-b"), {
        petId: "pet-b",
        vaccineName: "Rabies",
        dueDate: new Date(),
      }),
    );
  });

  it("blocks users from transferring a vaccination to another user's pet", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "pets/pet-a"), {
        ownerId: "user-a",
        name: "Cat A",
        category: "cat",
      });

      await setDoc(doc(context.firestore(), "pets/pet-b"), {
        ownerId: "user-b",
        name: "Cat B",
        category: "cat",
      });

      await setDoc(doc(context.firestore(), "vaccinations/vaccine-a"), {
        petId: "pet-a",
        vaccineName: "Rabies",
        dueDate: new Date(),
      });
    });

    await assertFails(
      setDoc(
        doc(userDb("user-a"), "vaccinations/vaccine-a"),
        { petId: "pet-b" },
        { merge: true },
      ),
    );
  });

  it("allows public reads of products", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "products/product-a"), {
        name: "Pet food",
        price: 50,
      });
    });

    await assertSucceeds(
      getDoc(doc(unauthenticatedDb(), "products/product-a")),
    );
  });

  it("blocks normal users from creating products", async () => {
    await assertFails(
      setDoc(doc(userDb("user-a"), "products/product-a"), {
        name: "Pet food",
        price: 50,
      }),
    );
  });

  it("allows admins to create products", async () => {
    await assertSucceeds(
      setDoc(doc(adminDb(), "products/product-a"), {
        name: "Pet food",
        price: 50,
      }),
    );
  });

  it("allows a user to add a valid cart item", async () => {
    await assertSucceeds(
      setDoc(doc(userDb("user-a"), "carts/user-a/items/product-a"), {
        productId: "product-a",
        variant: "",
        name: "Pet food",
        unitPrice: 50,
        imageUrl: "",
        quantity: 1,
        updatedAt: new Date(),
      }),
    );
  });

  it("blocks invalid cart quantities", async () => {
    await assertFails(
      setDoc(doc(userDb("user-a"), "carts/user-a/items/product-a"), {
        productId: "product-a",
        variant: "",
        name: "Pet food",
        unitPrice: 50,
        imageUrl: "",
        quantity: 0,
        updatedAt: new Date(),
      }),
    );

    await assertFails(
      setDoc(doc(userDb("user-a"), "carts/user-a/items/product-b"), {
        productId: "product-b",
        variant: "",
        name: "Pet food",
        unitPrice: 50,
        imageUrl: "",
        quantity: 101,
        updatedAt: new Date(),
      }),
    );
  });

  it("blocks a user from writing to another user's cart", async () => {
    await assertFails(
      setDoc(doc(userDb("user-a"), "carts/user-b/items/product-a"), {
        productId: "product-a",
        variant: "",
        name: "Pet food",
        unitPrice: 50,
        imageUrl: "",
        quantity: 1,
        updatedAt: new Date(),
      }),
    );
  });

  it("blocks customers from creating orders directly", async () => {
    await assertFails(
      setDoc(doc(userDb("user-a"), "orders/order-a"), {
        userId: "user-a",
        status: "confirmed",
        total: 50,
      }),
    );
  });

  it("blocks customers from reading another user's order", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "orders/order-b"), {
        userId: "user-b",
        total: 50,
      });
    });

    await assertFails(
      getDoc(doc(userDb("user-a"), "orders/order-b")),
    );
  });

  it("denies access to collections without explicit rules", async () => {
    await assertFails(
      getDocs(collection(userDb("user-a"), "medicalRecords")),
    );
  });

  it("blocks unauthenticated writes to the cart", async () => {
    await assertFails(
      setDoc(
        doc(unauthenticatedDb(), "carts/user-a/items/product-a"),
        {
          productId: "product-a",
          quantity: 1,
          unitPrice: 50,
        },
      ),
    );
  });
});
