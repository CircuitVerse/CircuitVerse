import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["link", "section", "dropdown"];

  connect() {
    // Bind once so removeEventListener works correctly
    this.boundSyncWithHash = this.syncWithHash.bind(this);

    // Sync UI with URL hash on initial load
    this.syncWithHash();

    // Keep sidebar and content in sync when hash changes
    window.addEventListener("hashchange", this.boundSyncWithHash);
  }

  disconnect() {
    window.removeEventListener("hashchange", this.boundSyncWithHash);
  }

  navigate(event) {
    event.preventDefault();

    const targetId = event.currentTarget
      .getAttribute("href")
      .replace("#", "");

    // Update hash explicitly
    window.location.hash = targetId;

    // Immediately sync UI
    this.activateSection(targetId);
  }

  syncWithHash() {
    const hash = window.location.hash.replace("#", "");
    if (!hash) return;

    this.activateSection(hash);
  }

  activateSection(id) {
    // Hide all sections
    this.sectionTargets.forEach(section => {
      section.classList.add("hidden");
    });

    // Remove active state from all links
    this.linkTargets.forEach(link => {
      link.classList.remove("active");
    });

    // Show active section
    const activeSection = this.sectionTargets.find(
      section => section.id === id
    );

    if (activeSection) {
      activeSection.classList.remove("hidden");
    }

    // Activate sidebar link
    const activeLink = this.linkTargets.find(
      link => link.getAttribute("href") === `#${id}`
    );

    if (activeLink) {
      activeLink.classList.add("active");

      // Expand parent dropdown if exists
      const parentDropdown =
        activeLink.closest("[data-api-docs-target='dropdown']");

      if (parentDropdown) {
        parentDropdown.classList.add("open");
      }
    }
  }
}
