# Google Summer of Code 2025 Proposal

## Personal Information
**Name**: Shree Meher  
**GitHub**: [https://github.com/s-meher](https://github.com/s-meher)  
**Email**: shreemeher05@gmail.com  
**University**: Illinois Institute of Technology, Chicago
**Time Zone**: UTC/GMT -5 hours

## Title
Migrate to ViewComponents & Improve Search Experience – CircuitVerse

## Synopsis
This project aims to modernize CircuitVerse’s UI components using ViewComponents in Ruby on Rails, ensuring better maintainability, performance, and scalability. It will also improve the search experience by optimizing query performance and enhancing the UI/UX, with added RTL (Right-to-Left) support and responsive design improvements.

## Benefits to the Community
- Reduces duplication and improves testability with modular ViewComponents.
- Offers a modern, intuitive and accessible search UI.
- Makes the platform more usable across devices and international users (RTL support).
- Enhances onboarding and contribution experience with cleaner code and reusable UI.

## Deliverables
- Migrate legacy views (ERB/partials) to ViewComponents (priority on search, profile, and explore pages).
- Refactor CSS using Bootstrap grid and utility classes.
- Improve search query logic and indexing for better performance.
- Enhance search results UI/UX (RTL, highlighting, filters, mobile-friendly).
- Document the new components for future contributors.
- Tests for components and search-related logic.

## Timeline

| Period | Task |
|--------|------|
| Community Bonding | Finalize list of views to migrate, understand current search logic, interact with mentors |
| Week 1–2 | Migrate 2–3 key views to ViewComponents and test |  
| Week 3–4 | Start refactoring search view, integrate search result filters and UX updates |  
| Midterm | Completed 50% ViewComponent migration + basic new search UI working |  
| Week 5–6 | Add RTL support + responsive design for mobile views |  
| Week 7–8 | Optimize query performance and indexing |  
| Week 9–10 | Add animations or frontend polish (Figma-to-Code) |  
| Final Weeks | Add tests + docs for components, polish UI and submit final report |

## Technical Approach
- Use [ViewComponent gem](https://viewcomponent.org/) for server-rendered reusable UI.
- Study and refactor `app/views/` files and convert to `app/components/`.
- Use Bootstrap’s responsive utilities + custom SCSS to clean layout issues.
- Refactor search controller/model for performance.
- Improve UX with Figma mockups and design tokens.
- Use tools like `pg_search`, `kaminari`, or simple index tuning for faster search.

## About Me
I'm a CS student with frontend experience in HTML, CSS, and JS, and actively learning Ruby on Rails. I’m passionate about clean, component-based UIs and making platforms more usable. CircuitVerse's mission and codebase excite me, and I'm eager to contribute to its modernization.

---

I'm ready to iterate and work closely with mentors to align with their roadmap for the platform.

