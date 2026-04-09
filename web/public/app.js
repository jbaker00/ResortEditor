import { firebaseConfig } from "./config.js";
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.14.0/firebase-app.js";
import {
  getAuth,
  signInWithPopup,
  signOut,
  GoogleAuthProvider,
  onAuthStateChanged,
} from "https://www.gstatic.com/firebasejs/10.14.0/firebase-auth.js";
import {
  getFirestore,
  collection,
  doc,
  getDoc,
  addDoc,
  setDoc,
  deleteDoc,
  onSnapshot,
  orderBy,
  query,
} from "https://www.gstatic.com/firebasejs/10.14.0/firebase-firestore.js";

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// ── DOM refs ─────────────────────────────────────────────────────────────────
const authScreen = document.getElementById("auth-screen");
const appScreen = document.getElementById("app-screen");
const signInBtn = document.getElementById("sign-in-btn");
const signOutBtn = document.getElementById("sign-out-btn");
const authError = document.getElementById("auth-error");
const addResortBtn = document.getElementById("add-resort-btn");
const resortList = document.getElementById("resort-list");
const modalOverlay = document.getElementById("modal-overlay");
const modalTitle = document.getElementById("modal-title");
const modalCloseBtn = document.getElementById("modal-close-btn");
const resortForm = document.getElementById("resort-form");
const formDocId = document.getElementById("form-doc-id");
const formName = document.getElementById("form-name");
const formCity = document.getElementById("form-city");
const formCountry = document.getElementById("form-country");
const formCategory = document.getElementById("form-category");
const formAirport = document.getElementById("form-airport");
const formImage = document.getElementById("form-image");
const formUrl = document.getElementById("form-url");
const formDescription = document.getElementById("form-description");
const formError = document.getElementById("form-error");
const formCancelBtn = document.getElementById("form-cancel-btn");

// ── State ─────────────────────────────────────────────────────────────────────
let resortsUnsubscribe = null;

// ── Auth ──────────────────────────────────────────────────────────────────────
onAuthStateChanged(auth, async (user) => {
  if (user) {
    const allowed = await checkAdminAllowlist(user.email);
    if (allowed) {
      showApp();
      startResortListener();
    } else {
      showError(authError, `Access denied. ${user.email} is not an authorized admin.`);
      await signOut(auth);
    }
  } else {
    showAuth();
    stopResortListener();
  }
});

signInBtn.addEventListener("click", async () => {
  hideError(authError);
  const provider = new GoogleAuthProvider();
  try {
    await signInWithPopup(auth, provider);
  } catch (err) {
    showError(authError, err.message);
  }
});

signOutBtn.addEventListener("click", () => signOut(auth));

async function checkAdminAllowlist(email) {
  const ref = doc(db, "resort_admins", email);
  const snap = await getDoc(ref);
  return snap.exists();
}

// ── Screen helpers ────────────────────────────────────────────────────────────
function showApp() {
  authScreen.classList.add("hidden");
  appScreen.classList.remove("hidden");
}

function showAuth() {
  appScreen.classList.add("hidden");
  authScreen.classList.remove("hidden");
}

// ── Resort listener ───────────────────────────────────────────────────────────
function startResortListener() {
  const q = query(collection(db, "Resorts"), orderBy("name"));
  resortsUnsubscribe = onSnapshot(q, (snapshot) => {
    renderResorts(snapshot.docs.map((d) => ({ id: d.id, ...d.data() })));
  });
}

function stopResortListener() {
  if (resortsUnsubscribe) {
    resortsUnsubscribe();
    resortsUnsubscribe = null;
  }
}

// ── Render ────────────────────────────────────────────────────────────────────
function renderResorts(resorts) {
  if (resorts.length === 0) {
    resortList.innerHTML = `<div class="empty-state">No resorts yet. Click <strong>+ Add Resort</strong> to get started.</div>`;
    return;
  }

  resortList.innerHTML = resorts
    .map(
      (r) => `
    <div class="resort-card">
      ${r.image ? `<img class="resort-img" src="${escHtml(r.image)}" alt="${escHtml(r.name)}" onerror="this.style.display='none'" />` : ""}
      <div class="resort-body">
        <h3>${escHtml(r.name)}</h3>
        <p class="resort-meta">${escHtml(r.city)}${r.city && r.country ? ", " : ""}${escHtml(r.country)}${r.category ? " · " + escHtml(r.category) : ""}</p>
        ${r.description ? `<p class="resort-desc">${escHtml(r.description)}</p>` : ""}
      </div>
      <div class="resort-actions">
        <button class="btn btn-sm btn-ghost" onclick="editResort(${escHtml(JSON.stringify(r.id))})">Edit</button>
        <button class="btn btn-sm btn-danger" onclick="deleteResort(${escHtml(JSON.stringify(r.id))}, ${escHtml(JSON.stringify(r.name))})">Delete</button>
      </div>
    </div>`
    )
    .join("");
}

function escHtml(str) {
  if (!str) return "";
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

// ── Modal ─────────────────────────────────────────────────────────────────────
addResortBtn.addEventListener("click", () => openModal(null));
modalCloseBtn.addEventListener("click", closeModal);
formCancelBtn.addEventListener("click", closeModal);
modalOverlay.addEventListener("click", (e) => {
  if (e.target === modalOverlay) closeModal();
});

function openModal(resort) {
  formDocId.value = resort?.id ?? "";
  formName.value = resort?.name ?? "";
  formCity.value = resort?.city ?? "";
  formCountry.value = resort?.country ?? "";
  formCategory.value = resort?.category ?? "";
  formAirport.value = resort?.airport ?? "";
  formImage.value = resort?.image ?? "";
  formUrl.value = resort?.url ?? "";
  formDescription.value = resort?.description ?? "";
  modalTitle.textContent = resort ? `Edit: ${resort.name}` : "New Resort";
  hideError(formError);
  modalOverlay.classList.remove("hidden");
  formName.focus();
}

function closeModal() {
  modalOverlay.classList.add("hidden");
  resortForm.reset();
}

// ── CRUD ──────────────────────────────────────────────────────────────────────
resortForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  hideError(formError);

  const data = {
    name: formName.value.trim(),
    city: formCity.value.trim(),
    country: formCountry.value.trim(),
    category: formCategory.value.trim(),
    airport: formAirport.value.trim(),
    image: formImage.value.trim(),
    url: formUrl.value.trim(),
    description: formDescription.value.trim(),
  };

  try {
    const id = formDocId.value;
    if (id) {
      await setDoc(doc(db, "Resorts", id), data);
    } else {
      await addDoc(collection(db, "Resorts"), data);
    }
    closeModal();
  } catch (err) {
    showError(formError, err.message);
  }
});

// Exposed to onclick handlers in rendered HTML
window.editResort = async (id) => {
  const snap = await getDoc(doc(db, "Resorts", id));
  if (snap.exists()) {
    openModal({ id: snap.id, ...snap.data() });
  }
};

window.deleteResort = async (id, name) => {
  if (!confirm(`Delete "${name}"? This cannot be undone.`)) return;
  try {
    await deleteDoc(doc(db, "Resorts", id));
  } catch (err) {
    alert("Error deleting resort: " + err.message);
  }
};

// ── Error helpers ─────────────────────────────────────────────────────────────
function showError(el, msg) {
  el.textContent = msg;
  el.classList.remove("hidden");
}

function hideError(el) {
  el.textContent = "";
  el.classList.add("hidden");
}
