# Timeline and Milestones (12 Weeks)

## Execution Principles
- Ship in small, reviewable increments.
- Prioritize correctness first, then UX quality.
- Keep MVP scope fixed and move non-essential work to stretch goals.

## Community Bonding (Weeks 1-2)
### Week 1: Setup and Architecture Mapping
- Complete local setup and test pipeline.
- Identify integration touchpoints for simulator data flow.
- Output: setup verified, architecture notes documented, one small onboarding contribution submitted.

### Week 2: Design Freeze (MVP)
- Finalize FSM schema, module boundaries, and error-handling strategy.
- Prepare wireframes for FSM input workflow.
- Output: mentor-reviewed design document with explicit MVP boundaries.

## Coding Phase 1 (Weeks 3-6): Core Engine
### Week 3: Parser and Validator
- Implement schema parser and validation rules.
- Add deterministic transition checks and invalid-input handling.
- Output: normalized FSM model + parser tests for valid/invalid cases.

### Week 4: State Encoding
- Implement deterministic binary state assignment.
- Generate truth-table inputs for sequential logic derivation.
- Output: encoded state map and transition truth tables for benchmark cases.

### Week 5: Equation Generation
- Generate next-state and output equations for Moore/Mealy variants.
- Add unit tests with known expected outputs.
- Output: equation generator passing benchmark validation tests.

### Week 6: Circuit Mapping
- Translate equations into CircuitVerse gate + flip-flop structures.
- Produce synthesis output compatible with simulator load/edit flow.
- Output: synthesized circuits open and execute in simulator tests.

## Midterm Evaluation (Week 7)
### MVP Demonstration
- End-to-end flow: define FSM → validate → synthesize → run circuit.
- Minimum demo coverage: one Moore and one Mealy machine.
- Midterm acceptance: mentor sign-off on functional MVP.

## Coding Phase 2 (Weeks 8-11): Productization
### Week 8: UI Integration
- Build FSM input UI and connect validation feedback.
- Improve form UX and error clarity.
- Output: no manual JSON required for typical FSM input.

### Week 9: Integration Hardening and Layout Baseline
- Connect UI to synthesis pipeline reliably.
- Improve generated placement/wiring readability.
- Output: stable end-to-end flow with readable baseline circuit output.

### Week 10: Feature Completion
- Stabilize Moore/Mealy parity across edge cases.
- Optional controlled-scope enhancement: one-hot encoding mode.
- Output: machine-mode parity verified by tests and demos.

### Week 11: Test and Reliability Pass
- Expand unit and integration coverage.
- Add safeguards for malformed input and complexity limits.
- Output: CI-green branch with documented test strategy.

## Finalization (Week 12)
### Documentation and Handoff
- Contributor docs: architecture, modules, extension points.
- User docs: FSM input workflow and synthesis usage.
- Final cleanup and refactor based on mentor review.
- Final acceptance: merge-ready or merged PR set with complete docs and test evidence.

## Milestone Matrix
| Milestone | Primary Output | Verification |
|---|---|---|
| M1 | Parser + Validator | Unit tests for valid/invalid FSM definitions |
| M2 | Encoding + Equation Engine | Benchmark FSM equation checks |
| M3 | Circuit Mapping | Synthesized circuit runs in simulator flow |
| M4 | UI + End-to-End Integration | Demo from input form to runnable circuit |
| M5 | Stability + Documentation | CI pass, docs complete, mentor review sign-off |

## Reporting Plan
- Weekly mentor update: completed work, blockers, next week goals.
- Demo checkpoint at each milestone boundary.
- Scope adjustment proposals documented before implementation changes.
