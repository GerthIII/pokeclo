import { Turbo } from "@hotwired/turbo-rails";

let pendingUrl = null;
let allowNextVisit = false;
let markRequestInFlight = false;
console.log("GUARD LOADED, Offcanvas source:", typeof Offcanvas)

const parsePendingItems = () => {
  const guardElement = document.getElementById("outfit-leave-guard");
  if (!guardElement) return [];

  try {
    const parsed = JSON.parse(guardElement.dataset.items || "[]");
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
};

const currentOffcanvas = () => {
  const offcanvasElement = document.getElementById("outfitLeaveOffcanvas");
  if (!offcanvasElement) return null;
  return window.bootstrap.Offcanvas.getOrCreateInstance(offcanvasElement);
};

const continueNavigation = () => {
  if (!pendingUrl) return;
  const nextUrl = pendingUrl;
  pendingUrl = null;
  allowNextVisit = true;
  Turbo.visit(nextUrl);
};

const markPendingItemsAsBought = async () => {
  if (markRequestInFlight) return;
  markRequestInFlight = true;

  try {
    const items = parsePendingItems();
    if (!items.length) {
      continueNavigation();
      return;
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    if (!csrfToken) {
      continueNavigation();
      return;
    }

    for (const item of items) {
      if (!item?.id) continue;
      await fetch(`/items/${item.id}/mark_as_bought`, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": csrfToken,
          Accept: "application/json"
        },
        credentials: "same-origin"
      });
    }
  } finally {
    markRequestInFlight = false;
    continueNavigation();
  }
};

document.addEventListener("turbo:before-visit", (event) => {
  if (allowNextVisit) {
    allowNextVisit = false;
    return;
  }

  const items = parsePendingItems();
  if (!items.length) return;

  const offcanvas = currentOffcanvas();
  if (!offcanvas) return;

  event.preventDefault();
  pendingUrl = event.detail.url;
  offcanvas.show();
});

document.addEventListener("click", (event) => {
  if (event.target.id === "leave-without-marking") {
    const offcanvas = currentOffcanvas();
    if (offcanvas) offcanvas.hide();
    continueNavigation();
  }
});

document.addEventListener("click", async (event) => {
  if (event.target.id !== "leave-mark-bought") return;

  const offcanvas = currentOffcanvas();
  if (offcanvas) offcanvas.hide();
  await markPendingItemsAsBought();
});

document.addEventListener("turbo:click", (event) => {
  if (allowNextVisit) return;

  const items = parsePendingItems();
  if (!items.length) return;

  const destination = event.detail?.url;
  const destinationUrl = destination?.toString?.() || null;
  if (!destinationUrl || destinationUrl === window.location.href) return;

  const offcanvas = currentOffcanvas();
  if (!offcanvas) return;

  event.preventDefault();
  pendingUrl = destinationUrl;
  offcanvas.show();
});
