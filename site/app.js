const versions = { API: "1.0.33", Worker: "1.0.32", Web: "1.0.37" };

function installCommand(service) {
  const lower = service.toLowerCase();
  const version = versions[service];
  const platform = service === "Web" ? "standalone" : "linux_amd64";
  const key = service.toUpperCase();
  return [
    "MQDECK_VERSION=1.0.3",
    `${key}_VERSION=${version}`,
    `curl -fLO "https://github.com/mqdeck/mqdeck/releases/download/v\${MQDECK_VERSION}/mqdeck-${lower}_\${${key}_VERSION}_${platform}.tar.gz"`,
    `tar -xzf "mqdeck-${lower}_\${${key}_VERSION}_${platform}.tar.gz"`,
    `cd "mqdeck-${lower}_\${${key}_VERSION}_${platform}"`,
    `sudo ./install-${lower}.sh`,
    `sudo systemctl enable --now mqdeck-${lower}`,
  ].join("\n");
}

const command = document.querySelector("[data-command]");
const label = document.querySelector("[data-terminal-label]");
const note = document.querySelector("[data-copy-note]");
const copyLabel = document.querySelector("[data-copy-label]");
let service = "API";

function renderInstall() {
  command.textContent = installCommand(service);
  label.innerHTML = `${service} on RHEL <span> / v${versions[service]}</span>`;
  document.getElementById("install-panel").setAttribute("aria-labelledby", `tab-${service}`);
  document.querySelectorAll("[data-service]").forEach((button) => {
    button.setAttribute("aria-selected", button.dataset.service === service ? "true" : "false");
  });
}

document.querySelectorAll("[data-service]").forEach((button) => {
  button.addEventListener("click", () => {
    service = button.dataset.service;
    copyLabel.textContent = "Copy";
    note.textContent = "Public release v1.0.3 · Linux deployment";
    renderInstall();
  });
});

document.querySelector("[data-copy]").addEventListener("click", async () => {
  try {
    await navigator.clipboard.writeText(installCommand(service));
    copyLabel.textContent = "Copied";
    note.textContent = "Public release v1.0.3 · Linux deployment";
    window.setTimeout(() => {
      copyLabel.textContent = "Copy";
    }, 2000);
  } catch {
    note.textContent = "Could not copy. Select the command above to copy it manually.";
  }
});

const menu = document.querySelector("[data-menu]");
const mobileNav = document.querySelector("[data-mobile-nav]");
menu.addEventListener("click", () => {
  const open = mobileNav.hasAttribute("hidden");
  mobileNav.toggleAttribute("hidden", !open);
  menu.setAttribute("aria-expanded", open ? "true" : "false");
  menu.setAttribute("aria-label", open ? "Close menu" : "Open menu");
  menu.querySelector("[data-icon-open]").toggleAttribute("hidden", open);
  menu.querySelector("[data-icon-close]").toggleAttribute("hidden", !open);
});
mobileNav.querySelectorAll("a").forEach((link) => {
  link.addEventListener("click", () => {
    mobileNav.setAttribute("hidden", "");
    menu.setAttribute("aria-expanded", "false");
    menu.setAttribute("aria-label", "Open menu");
    menu.querySelector("[data-icon-open]").removeAttribute("hidden");
    menu.querySelector("[data-icon-close]").setAttribute("hidden", "");
  });
});

renderInstall();
