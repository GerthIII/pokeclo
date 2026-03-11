import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static targets = ["itemCheckbox"];

  static values = {
    items: Array
  };

  connect() {
    this.pendingUrl = null;
    this.allowNextVisit = false;
    this.markRequestInFlight = false;

    this.beforeVisitHandler = this.handleBeforeVisit.bind(this);
    this.turboClickHandler = this.handleTurboClick.bind(this);
    this.documentClickHandler = this.handleDocumentClick.bind(this);

    document.addEventListener("turbo:before-visit", this.beforeVisitHandler);
    document.addEventListener("turbo:click", this.turboClickHandler);
    document.addEventListener("click", this.documentClickHandler, true);
  }

  disconnect() {
    document.removeEventListener("turbo:before-visit", this.beforeVisitHandler);
    document.removeEventListener("turbo:click", this.turboClickHandler);
    document.removeEventListener("click", this.documentClickHandler, true);
  }

  leaveWithoutMarking(event) {
    event.preventDefault();
    const offcanvas = this.currentOffcanvas();
    if (offcanvas) offcanvas.hide();
    this.continueNavigation();
  }

  async leaveAndMarkBought(event) {
    event.preventDefault();
    const offcanvas = this.currentOffcanvas();
    if (offcanvas) offcanvas.hide();
    await this.markPendingItemsAsBought();
  }

  pendingItems() {
    if (Array.isArray(this.itemsValue) && this.itemsValue.length) return this.itemsValue;
    return this.itemCheckboxTargets.map((checkbox) => ({ id: checkbox.value }));
  }

  selectedItemIds() {
    return this.itemCheckboxTargets
      .filter((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.value)
      .filter((id) => id);
  }

  currentOffcanvas() {
    if (!window.bootstrap?.Offcanvas) return null;
    return window.bootstrap.Offcanvas.getOrCreateInstance(this.element);
  }

  continueNavigation() {
    if (!this.pendingUrl) return;
    const nextUrl = this.pendingUrl;
    this.pendingUrl = null;
    this.allowNextVisit = true;
    Turbo.visit(nextUrl);
  }

  async markPendingItemsAsBought() {
    if (this.markRequestInFlight) return;
    this.markRequestInFlight = true;

    try {
      const itemIds = this.selectedItemIds();
      if (!itemIds.length) {
        this.continueNavigation();
        return;
      }

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
      if (!csrfToken) {
        this.continueNavigation();
        return;
      }

      for (const itemId of itemIds) {
        await fetch(`/items/${itemId}/mark_as_bought`, {
          method: "PATCH",
          headers: {
            "X-CSRF-Token": csrfToken,
            Accept: "application/json"
          },
          credentials: "same-origin"
        });
      }
    } finally {
      this.markRequestInFlight = false;
      this.continueNavigation();
    }
  }

  handleBeforeVisit(event) {
    if (this.allowNextVisit) {
      this.allowNextVisit = false;
      return;
    }

    if (!this.pendingItems().length) return;
    if (this.shouldSkipPrompt(event.detail.url)) return;
    if (this.pendingUrl && event.detail.url?.toString?.() === this.pendingUrl) {
      event.preventDefault();
      return;
    }

    const offcanvas = this.currentOffcanvas();
    if (!offcanvas) return;

    event.preventDefault();
    this.pendingUrl = event.detail.url?.toString?.() || event.detail.url;
    offcanvas.show();
  }

  handleDocumentClick(event) {
    if (this.allowNextVisit) return;
    if (!this.pendingItems().length) return;

    // Allow offcanvas controls to work normally.
    if (event.target.closest("#outfitLeaveOffcanvas")) return;

    const link = event.target.closest("a[href]");
    if (!link) return;
    if (link.target && link.target !== "_self") return;
    if (link.hasAttribute("download")) return;
    if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
    if (event.button !== 0) return;

    const destinationUrl = link.href;
    if (!destinationUrl || destinationUrl === window.location.href) return;
    if (this.shouldSkipPrompt(destinationUrl) || link.dataset.skipPurchasePrompt === "true") return;

    const offcanvas = this.currentOffcanvas();
    if (!offcanvas) return;

    event.preventDefault();
    event.stopPropagation();
    this.pendingUrl = destinationUrl;
    offcanvas.show();
  }

  handleTurboClick(event) {
    if (this.allowNextVisit) return;
    if (!this.pendingItems().length) return;

    const destination = event.detail?.url;
    const destinationUrl = destination?.toString?.() || null;
    if (!destinationUrl || destinationUrl === window.location.href) return;
    if (this.shouldSkipPrompt(destinationUrl)) return;

    const offcanvas = this.currentOffcanvas();
    if (!offcanvas) return;

    event.preventDefault();
    this.pendingUrl = destinationUrl;
    offcanvas.show();
  }

  shouldSkipPrompt(urlLike) {
    const url = this.normalizeUrl(urlLike);
    if (!url) return false;

    // Don't block try-on navigation with the purchase offcanvas prompt.
    return /\/outfits\/[^/]+\/try_on$/.test(url.pathname);
  }

  normalizeUrl(urlLike) {
    if (!urlLike) return null;

    try {
      return urlLike instanceof URL ? urlLike : new URL(urlLike.toString(), window.location.origin);
    } catch (_error) {
      return null;
    }
  }
}
