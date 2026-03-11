const bindNavbarMenuOverlay = () => {
  const menu = document.getElementById("navbarSupportedContent");
  if (!menu) return;

  setOverlay(menu.classList.contains("show"));

  menu.addEventListener("shown.bs.collapse", () => setOverlay(true));
  menu.addEventListener("hidden.bs.collapse", () => setOverlay(false));
};

document.addEventListener("turbo:load", bindNavbarMenuOverlay);
document.addEventListener("turbo:before-cache", () => {
  document.body.classList.remove("menu-overlay-active");
});
