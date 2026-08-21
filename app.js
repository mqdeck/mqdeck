const header = document.querySelector("[data-header]");
const navigation = document.querySelector("[data-navigation]");
const menuToggle = document.querySelector("[data-menu-toggle]");

function updateHeader() {
  header?.classList.toggle("is-scrolled", window.scrollY > 16);
}

function closeNavigation() {
  navigation?.classList.remove("is-open");
  menuToggle?.setAttribute("aria-expanded", "false");
}

menuToggle?.addEventListener("click", () => {
  const open = !navigation?.classList.contains("is-open");
  navigation?.classList.toggle("is-open", open);
  menuToggle.setAttribute("aria-expanded", String(open));
});

navigation?.querySelectorAll("a").forEach((link) => {
  link.addEventListener("click", closeNavigation);
});

window.addEventListener("scroll", updateHeader, { passive: true });
window.addEventListener("resize", () => {
  if (window.innerWidth > 820) closeNavigation();
});
updateHeader();

const installer = document.querySelector("[data-installer]");
const installTabs = Array.from(document.querySelectorAll("[data-install-tab]"));
const installPanels = Array.from(document.querySelectorAll("[data-install-panel]"));

function selectInstallTab(name) {
  installTabs.forEach((tab) => {
    const selected = tab.dataset.installTab === name;
    tab.setAttribute("aria-selected", String(selected));
    tab.tabIndex = selected ? 0 : -1;
  });
  installPanels.forEach((panel) => {
    panel.hidden = panel.dataset.installPanel !== name;
  });
}

installTabs.forEach((tab, index) => {
  tab.addEventListener("click", () => selectInstallTab(tab.dataset.installTab));
  tab.addEventListener("keydown", (event) => {
    if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return;
    event.preventDefault();
    const direction = event.key === "ArrowRight" ? 1 : -1;
    const nextIndex = (index + direction + installTabs.length) % installTabs.length;
    const nextTab = installTabs[nextIndex];
    selectInstallTab(nextTab.dataset.installTab);
    nextTab.focus();
  });
});

installer?.querySelectorAll("[data-copy]").forEach((button) => {
  button.addEventListener("click", async () => {
    const target = document.querySelector(button.dataset.copy);
    const status = installer.querySelector("[data-copy-status]");
    if (!target || !status) return;

    try {
      await navigator.clipboard.writeText(target.textContent.trim());
      status.textContent = "Command copied to clipboard.";
      button.textContent = "Copied";
      window.setTimeout(() => {
        status.textContent = "";
        button.textContent = "Copy";
      }, 2200);
    } catch {
      status.textContent = "Select the command and copy it manually.";
    }
  });
});

document.querySelectorAll("[data-current-year]").forEach((element) => {
  element.textContent = String(new Date().getFullYear());
});
