document.addEventListener("DOMContentLoaded", function () {
  const searchIcons = document.getElementsByClassName("fa-search");
  const searchBar = document.getElementsByClassName("navbar-search-active")[0];
  const dropdownButton = document.getElementById("dropdownButton");
  const dropdownIcon = document.getElementById("dropdownIcon");
  const collapseElement = document.getElementById("collapsed-navbar");
  const gettingStartedLink = document.querySelector("#getting-started-dropdown");
  const navbar = document.querySelector(".navbar");

  function handleNavbarShadow() {
    if (!navbar) return;
    if (window.scrollY > 0) {
      navbar.classList.add("affix");
    } else {
      navbar.classList.remove("affix");
    }
  }

  window.addEventListener("scroll", handleNavbarShadow);

  if (gettingStartedLink && window.bootstrap) {
    const gettingStartedDropdown = new bootstrap.Dropdown(gettingStartedLink);
    gettingStartedLink.addEventListener("click", function (e) {
      if (gettingStartedLink.classList.contains("rotate180")) {
        gettingStartedLink.classList.remove("rotate180");
        gettingStartedDropdown.hide();
      } else {
        gettingStartedLink.classList.add("rotate180");
        gettingStartedDropdown.show();
      }
      e.stopPropagation();
    });
    document.addEventListener("click", function () {
      gettingStartedLink.classList.remove("rotate180");
      gettingStartedDropdown.hide();
    });
  }

  function activeSearchBar() {
    if (!searchBar) return;
    const icons = Array.from(searchIcons);
    const isActive = icons.some((icon) => icon.classList.contains("active"));
    if (isActive) {
      icons.forEach((icon) => icon.classList.remove("active"));
      searchBar.style.display = "none";
    } else {
      icons.forEach((icon) => icon.classList.add("active"));
      searchBar.style.display = "block";
    }
    if (collapseElement) collapseElement.classList.remove("show");
  }

  if (dropdownButton && collapseElement && dropdownIcon && window.bootstrap) {
    const bsCollapse = new bootstrap.Collapse(collapseElement, { toggle: false });
    collapseElement.addEventListener("show.bs.collapse", function () {
      dropdownIcon.classList.replace("fa-bars", "fa-times");
      dropdownButton.setAttribute("aria-expanded", "true");
    });
    collapseElement.addEventListener("hide.bs.collapse", function () {
      dropdownIcon.classList.replace("fa-times", "fa-bars");
      dropdownButton.setAttribute("aria-expanded", "false");
    });
    dropdownButton.addEventListener("click", function (e) {
      e.preventDefault();
      bsCollapse.toggle();
    });
  }

  Array.from(searchIcons).forEach((icon) => icon.addEventListener("click", activeSearchBar));

  if (searchBar && window.location.href.includes("search")) {
    searchBar.style.display = "block";
    Array.from(searchIcons).forEach((icon) => icon.classList.add("active"));
  }

  function setActiveNavbarItem() {
    const navLinks = Array.from(document.querySelectorAll(".main-nav-items a.navbar-item.navbar-text")).filter(
      (link) => {
        const href = link.getAttribute("href") || "";
        if (!href) return false;
        if (link.matches('[data-bs-toggle="dropdown"]')) return false;
        if (link.classList.contains("navbar-user-dropdown")) return false;
        return href.startsWith("/") || href.startsWith("#");
      }
    );

    navLinks.forEach((link) => link.classList.remove("active"));

    const currentPath = window.location.pathname;
    const currentHash = window.location.hash;

    const normalizedPath = currentPath.endsWith("/") && currentPath !== "/" ? currentPath.slice(0, -1) : currentPath;

    if (normalizedPath === "/" && currentHash) {
      const hashMatch = navLinks.find((link) => {
        const href = link.getAttribute("href") || "";
        try {
          const linkHash = new URL(href, window.location.origin).hash;
          return linkHash === currentHash;
        } catch (_) {
          return false;
        }
      });

      if (hashMatch) {
        hashMatch.classList.add("active");
      }
      return;
    }

    const pathMatch = navLinks.find((link) => {
      const href = link.getAttribute("href") || "";
      if (!href.startsWith("/")) return false;
      const hrefPath = href.split("#")[0];
      const normalizedHrefPath = hrefPath.endsWith("/") && hrefPath !== "/" ? hrefPath.slice(0, -1) : hrefPath;
      return normalizedHrefPath === normalizedPath;
    });

    if (pathMatch) {
      pathMatch.classList.add("active");
    }
  }

  setActiveNavbarItem();
  window.addEventListener("hashchange", setActiveNavbarItem);
  window.addEventListener("popstate", setActiveNavbarItem);
});
