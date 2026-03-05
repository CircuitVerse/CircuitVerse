# Execution Autopilot Checklist (Selection Maximizer)

Use this checklist in order without re-planning.

## Phase A — Publish Mentor Signals (Today)
- [ ] Post Slack short message from `GoSC/07-Mentor-Outreach-and-PR-Plan.md`
- [ ] Open GitHub Discussion draft from same file
- [ ] Attach links:
  - `GoSC/06-One-Page-Design.md`
  - `GoSC/02-Timeline-and-Milestones.md`
  - `GoSC/poc/README.md`

## Phase B — Turn Prepared Changes into PRs

## PR #1 (already prepared)
**Title:** fix(api): correct circuit_data not-found error message typo

**Files already changed in workspace:**
- `app/controllers/api/v1/projects_controller.rb`
- `spec/requests/api/v1/projects_controller/circuit_data_spec.rb`

**Suggested commit message:**
`fix(api): correct circuit_data unavailable error message`

## PR #2 (already prepared)
**Title:** refactor(api): remove redundant double update in projects update endpoint

**File already changed in workspace:**
- `app/controllers/api/v1/projects_controller.rb`

**Suggested commit message:**
`refactor(api): remove duplicate update call in projects controller`

## Optional PR #3 (quick follow-up)
- Remove duplicate middleware registration in `config/application.rb`
- Add/adjust any configuration spec if available

## Phase C — POC Evidence Package
- [ ] Run POC checker and keep terminal output screenshot
  - `node GoSC/poc/poc_check.js`
- [ ] Record 60-90 second walkthrough:
  - input sample file
  - generated equations
  - logic block summary
- [ ] Add these artifacts to mentor thread

## Phase D — Proposal Finalization
- [ ] Fill placeholders in `GoSC/00-Master-Submission-Template-Aligned.md`
- [ ] Add real PR links under pre-proposal section
- [ ] Ensure hour split remains 175 and milestones are unchanged
- [ ] Final proofreading pass for clarity and consistency

## Phase E — Review Hygiene (Critical)
- [ ] Keep each PR single-purpose
- [ ] Include test evidence in PR description
- [ ] Explicitly document edge cases considered
- [ ] Respond to review comments within 24h

## Daily KPI Targets (This Week)
- 1 mentor-visible update/day
- 1 concrete artifact/day (doc, code, PR, or demo)
- 1 reviewer-ready PR every 2 days

## Non-Negotiables
- Do not expand scope beyond MVP without mentor feedback.
- Do not batch unrelated fixes into one PR.
- Do not delay communication when blocked.
