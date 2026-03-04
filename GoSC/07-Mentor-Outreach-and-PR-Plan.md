# Mentor Outreach + PR Start Plan (Project 3)

## 1) Slack Message (Short Version)
Hi mentors 👋

I’m planning to apply for **GSoC 2026 Project 3 (FSM to Circuit Synthesizer)** and have prepared initial drafts to validate scope early.

- One-page design: `GoSC/06-One-Page-Design.md`
- Timeline + milestones: `GoSC/02-Timeline-and-Milestones.md`
- This-week lock-in plan: `GoSC/05-This-Week-Lock-In-Plan.md`

Current MVP scope:
1. Structured/tabular FSM input
2. Deterministic validation + state encoding
3. Moore/Mealy equation generation
4. CircuitVerse-compatible generated logic blocks/circuit structure

Could you please review and share guidance on:
1. Is this MVP scope realistic for 175 hours?
2. Should I implement Moore-first then Mealy, or both in parallel from week 1 of coding?
3. Which integration boundary should I target first for least-risk reviews?

I’m also starting 1-2 small PRs this week (test/bugfix focused) to demonstrate execution before proposal review.

## 2) Slack Message (Detailed Version)
Hello mentors,

I’m preparing my GSoC 2026 application for **Project 3: FSM to Circuit Synthesizer** and wanted to validate my technical direction early.

Prepared drafts:
- One-page design (`GoSC/06-One-Page-Design.md`): schema, Moore/Mealy conversion flow, output representation
- Timeline (`GoSC/02-Timeline-and-Milestones.md`): week-by-week milestones and acceptance checkpoints
- Weekly execution plan (`GoSC/05-This-Week-Lock-In-Plan.md`): immediate deliverables before proposal review

MVP boundaries I’m proposing:
- Tabular/structured FSM input only (no advanced graph editor initially)
- Deterministic validation and binary state encoding
- Boolean generation for next-state/output logic
- Circuit mapping to editable CircuitVerse-compatible output

Questions for mentor alignment:
1. Is this MVP boundary appropriate for 175 hours?
2. For lower implementation risk, should I sequence Moore-first then Mealy?
3. Which existing simulator/data-flow interfaces are best for first integration?

I’ll also submit 1-2 small PRs this week (preferably test-focused) to show implementation quality before proposal review.

Thank you for any feedback.

## 3) GitHub Discussion Draft
**Title:** GSoC 2026 Project 3 Draft Scope + MVP Design Review Request

Hello CircuitVerse mentors and contributors,

I am planning to apply for **GSoC 2026 Project 3: FSM to Circuit Synthesizer**. I prepared an initial draft and would appreciate early feedback on scope and technical direction.

### Drafts
- One-page design: `GoSC/06-One-Page-Design.md`
- Timeline and milestones: `GoSC/02-Timeline-and-Milestones.md`
- This-week lock-in plan: `GoSC/05-This-Week-Lock-In-Plan.md`

### Proposed MVP
- Structured/tabular FSM input
- Deterministic validation + state encoding
- Moore/Mealy equation generation
- CircuitVerse-compatible generated sequential circuit output

### Questions
1. Is this MVP scope realistic for 175 hours?
2. Is Moore-first then Mealy the best sequencing strategy?
3. Which simulator integration boundary should be targeted first for reliability and review efficiency?

I am also preparing 1-2 contribution PRs this week (bugfix/tests) to demonstrate execution before proposal review.

Thank you for your guidance.

## 4) PR Start Checklist (This Week)
- [ ] Pick PR #1: test-focused bugfix (small scope)
- [ ] Pick PR #2: optional FSM-adjacent utility/docs improvement
- [ ] Confirm issue is not `pending triage`
- [ ] Comment and claim issue
- [ ] Reproduce issue locally
- [ ] Add/adjust tests first (where feasible)
- [ ] Keep PR small (single concern)
- [ ] Fill PR template completely with approach and edge cases
- [ ] Link PR back in mentor thread

## 5) PR Candidate Filters
Prioritize issues/changes that are:
- `good first issue` or `help wanted`
- Tagged to platform/backend areas you can ship quickly
- Test-heavy or reliability-related
- Related to simulator/project data flow, validation, or API behavior

## 6) Weekly Status Update Template
This week’s progress (Project 3 prep):
- Completed:
  - [doc/design link]
  - [POC/demo link]
  - [PR links]
- In progress:
  - [short item]
- Blockers:
  - [short blocker + needed feedback]
- Next week:
  - [next 2-3 deliverables]
