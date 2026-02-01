import { Controller } from "stimulus";

export default class extends Controller {
    connect() {
        this.collapseElement = document.getElementById("collapsed-navbar");

        this.navbarLinks = Array.from(
            this.element.querySelectorAll('.navbar-nav .nav-link[href*="#"]'),
        ).filter((l) => {
            return l.hash || (l.getAttribute("href") || "").includes("#");
        });

        this.idToLink = {};
        this.sections = this.navbarLinks
            .map((l) => {
                const href = l.getAttribute("href") || "";
                const hash =
                    l.hash && l.hash.length > 1
                        ? l.hash
                        : `#${href.split("#")[1] || ""}`;
                const id = hash.replace(/^#/, "");
                const el = document.getElementById(id);
                if (el) {
                    this.idToLink[id] = l;
                }

                return el;
            })
            .filter(Boolean);

        if (!this.sections.length) return;

        this.handleIntersections = this.handleIntersections.bind(this);
        this.observer = new IntersectionObserver(this.handleIntersections, {
            threshold: [0, 0.25, 0.5, 0.75, 1],
            rootMargin: "-10% 0px -40% 0px",
        });

        this.sections.forEach((s) => {
            this.observer.observe(s);
        });

        // scroll back, reverts to original state
        this.clickHandlers = [];
        this.navbarLinks.forEach((link) => {
            const handler = () => {
                this.navbarLinks.forEach((a) => {
                    a.classList.remove("active");
                });
                link.classList.add("active");
                if (this.collapseElement) {
                    const inst =
                        bootstrap.Collapse.getInstance(this.collapseElement) ||
                        new bootstrap.Collapse(this.collapseElement, {
                            toggle: false,
                        });
                    if (this.collapseElement.classList.contains("show")) {
                        inst.hide();
                    }
                }
            };
            link.addEventListener("click", handler);
            this.clickHandlers.push({ link, handler });
        });

        if (window.location.hash) {
            const id = window.location.hash.replace(/^#/, "");
            if (this.idToLink[id]) {
                this.navbarLinks.forEach((a) => {
                    a.classList.remove("active");
                });
                this.idToLink[id].classList.add("active");
            }
        }

        // other navbar links
        const { pathname } = window.location;
        const topLevelLinks = Array.from(
            this.element.querySelectorAll('.navbar-nav .nav-link[href^="/"]'),
        ).filter((l) => !(l.getAttribute("href") || "").includes("#"));
        topLevelLinks.forEach((l) => {
            try {
                const hrefPath = new URL(l.href, window.location.origin)
                    .pathname;
                if (hrefPath === pathname) {
                    topLevelLinks.forEach((a) => {
                        a.classList.remove("active");
                    });
                    l.classList.add("active");
                }
            } catch (err) {
                console.warn("navbar: invalid href for link", l, err);
            }
        });
    }

    handleIntersections(entries) {
        let best = null;
        entries.forEach((entry) => {
            if (entry.isIntersecting) {
                if (!best || entry.intersectionRatio > best.intersectionRatio) {
                    best = entry;
                }
            }
        });

        if (best) {
            Object.values(this.idToLink).forEach((a) => {
                a.classList.remove("active");
            });
            const link = this.idToLink[best.target.id];
            if (link) {
                link.classList.add("active");
            }
        } else {
            Object.values(this.idToLink).forEach((a) => {
                a.classList.remove("active");
            });
        }
    }

    disconnect() {
        if (this.observer) {
            this.observer.disconnect();
            this.observer = null;
        }

        if (this.clickHandlers) {
            this.clickHandlers.forEach(({ link, handler }) => {
                link.removeEventListener("click", handler);
            });
            this.clickHandlers = null;
        }
    }
}
