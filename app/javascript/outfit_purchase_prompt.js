let promptInFlight = false;
let lastPromptRunAt = 0;

const promptToMarkBought = async () => {
  const now = Date.now();
  if (promptInFlight || now - lastPromptRunAt < 250) return;

  const promptData = document.getElementById("purchase-status-prompts");
  if (!promptData) return;

  const rawItems = promptData.dataset.items;
  if (!rawItems) return;

  let items;
  try {
    items = JSON.parse(rawItems);
  } catch {
    return;
  }

  if (!Array.isArray(items) || items.length === 0) return;

  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
  if (!csrfToken) return;

  // Commit only after all guards pass
  promptInFlight = true;
  lastPromptRunAt = now;

  try {
    for (const item of items) {
      if (!item?.id) continue;

      const itemName = item.name || "this item";
      const didBuy = window.confirm(`Did you buy "${itemName}"?`);
      if (!didBuy) continue;

      const response = await fetch(`/items/${item.id}/mark_as_bought`, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        credentials: "same-origin",
      });

      if (!response.ok) {
        console.error(`Failed to mark item ${item.id} as bought: ${response.status}`);
      }
    }
  } finally {
    promptInFlight = false;
  }
};

document.addEventListener("turbo:load", promptToMarkBought);
window.addEventListener("pageshow", promptToMarkBought);
