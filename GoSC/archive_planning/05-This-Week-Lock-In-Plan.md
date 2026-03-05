# This Week Lock-In Plan (Project 3)

## Objective
By end of week, confirm Project 3 choice with visible progress:
1) one-page design,
2) small proof of concept,
3) mentor discussion thread,
4) 1-2 contribution PRs.

## Success Criteria (End of Week)
- One-page FSM design draft posted and shared.
- POC demo artifact available (repo, screenshots, short clip, or gist).
- One mentor-facing discussion opened with milestones + scoped questions.
- 1-2 CircuitVerse PRs submitted (preferably at least one test-focused PR).

## Day-by-Day Plan

### Day 1 (Today): One-Page Design Draft
- Create one-page design section with:
  - FSM schema (state, input, transition, output).
  - Moore and Mealy conversion pipeline.
  - Output circuit representation assumptions.
- Keep it short and implementation-first.
- Save draft under GoSC with revision date.

### Day 2: POC Skeleton
- Build minimal FSM input parser for 3-5 states.
- Add deterministic state encoding (binary).
- Generate basic next-state/output expressions.
- Render simple generated logic block structure (does not need polished layout).

### Day 3: POC Validation + Demo
- Run 2 benchmark examples:
  - one Moore sample,
  - one Mealy sample.
- Capture outputs and expected behavior comparison.
- Prepare a 60-90 second demo clip or screenshots.

### Day 4: Mentor Discussion Post
- Open one concise thread in Slack/GitHub Discussions with:
  - project choice confirmation,
  - one-page design summary,
  - POC demo artifacts,
  - milestone proposal,
  - 3 targeted questions.

### Day 5-6: Contribution PRs
- Submit PR #1 (test-focused bugfix or reliability improvement).
- Submit PR #2 (optional) FSM-adjacent utility/doc improvement.
- Keep both PRs small and review-friendly.

### Day 7: Weekly Wrap
- Post weekly update summary:
  - what shipped,
  - links to docs/discussion/PRs,
  - blockers and next-week goals.

## One-Page Design: Recommended Outline
1. Problem and user flow
2. FSM data model
3. Moore vs Mealy handling
4. Synthesis pipeline stages
5. Output circuit format and assumptions
6. MVP limits and non-goals
7. Test strategy

## POC Scope (Strict MVP)
- Input: structured FSM JSON/table (no advanced graph UI).
- Engine:
  - validator,
  - encoder,
  - equation generator,
  - logic block generator.
- Output: readable intermediate representation and/or basic simulator-compatible object draft.

## Mentor Discussion Template
Title: GSoC 2026 Project 3 Draft Plan + Early POC

Hello mentors, I am planning to apply for Project 3 (FSM to Circuit Synthesizer).

This week I prepared:
- one-page design draft: [link]
- POC (3-5 states, Moore/Mealy examples): [link]
- proposed 12-week milestones: [link]

Current MVP scope:
- tabular/structured FSM input,
- deterministic validation + state encoding,
- equation generation,
- generated logic blocks/circuit mapping baseline.

Questions:
1) Is this MVP scope appropriate for 175 hours?
2) For initial implementation, should I prioritize Moore-first and then Mealy, or both in parallel?
3) Which integration boundary should I target first for lower review risk?

I also plan to submit 1-2 PRs this week to demonstrate execution quality before proposal review.

## PR Ideas You Can Start Immediately
- Add tests for parser/validation edge cases in existing simulator-related paths.
- Small bugfix in project/simulator data validation with regression test.
- Documentation clarity improvement in setup/contributing paths with technical examples.

## Weekly Risk Controls
- If POC complexity grows, freeze to Moore-first and keep Mealy in staged milestone.
- If PR review slows, split changes into smaller PRs with isolated tests.
- If design ambiguity appears, ask mentor questions early before coding further.

## Weekly Deliverables Checklist
- [ ] One-page design finalized
- [ ] POC built (3-5 states)
- [ ] Moore test case passes
- [ ] Mealy test case passes
- [ ] Mentor discussion opened
- [ ] PR #1 submitted
- [ ] PR #2 submitted or scoped
- [ ] Weekly wrap posted
