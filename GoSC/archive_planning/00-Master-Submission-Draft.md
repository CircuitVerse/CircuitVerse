# GSoC 2026 Proposal Draft

## Project Title
FSM to Circuit Synthesizer

## Organization
CircuitVerse

## Project Category
Project 3 (175 hours)

## Applicant Information
- Name: Umair
- Timezone: [Fill]
- Email: [Fill]
- GitHub: [Fill]
- Resume/Portfolio: [Fill]

## Abstract
Finite State Machines are a core topic in digital logic, but learners often struggle to manually convert state behavior into gate-level circuits. CircuitVerse currently provides strong circuit-building tools, yet it lacks an end-to-end FSM workflow.

This proposal introduces an FSM-to-circuit synthesizer that lets users define Moore or Mealy machines and automatically generate equivalent, editable CircuitVerse circuits.

## Problem Statement and Motivation
- Students and educators spend significant time translating state tables/diagrams into sequential logic manually.
- Manual conversion introduces correctness errors in state encoding, transition logic, and output logic.
- CircuitVerse can improve learning outcomes by automating conversion while keeping generated circuits transparent and editable.

## Project Goals
1. Build a guided FSM definition workflow (MVP: structured/tabular input).
2. Support both Moore and Mealy machine models.
3. Synthesize FSM definitions into CircuitVerse-compatible sequential circuits.
4. Ensure functional correctness through tests and reproducible validation.

## Scope
### In Scope
- FSM schema/model for states, transitions, inputs, and outputs.
- Validation and normalization pipeline with user-facing error messages.
- State encoding module (binary for MVP).
- Equation generation module (next-state and output logic).
- Circuit mapping module (flip-flops + combinational gates).
- UI integration: define FSM → validate → synthesize.
- Test suite and contributor documentation.

### Out of Scope (MVP)
- Fully featured graphical FSM editor with advanced interaction tooling.
- Large-scale formal minimization for very high variable counts.
- Non-FSM automata targets (NFA/PDA/TM).

## Technical Design
### 1) FSM Data Contract
A normalized JSON model will define machine type, symbols, states, transitions, and output semantics.

### 2) Validation and Normalization
- Verify determinism and transition completeness for the selected alphabet.
- Reject malformed/ambiguous definitions with actionable error feedback.

### 3) State Encoding
- Assign state codes deterministically.
- Build truth tables for flip-flop inputs and output functions.

### 4) Logic Generation
- Generate Boolean equations for next-state and output logic.
- Reuse existing combinational logic patterns from CircuitVerse where feasible.

### 5) Circuit Synthesis Layer
- Translate equations into a CircuitVerse-compatible circuit structure.
- Generate an editable circuit that opens directly in simulator flow.

### 6) Product Integration
- Add synthesis entry point in UI with clear workflow and validation states.
- Keep generated circuits modifiable by users after synthesis.

## Deliverables and Acceptance Criteria
1. **End-to-end synthesis MVP**
   - Acceptance: at least two reference FSMs (one Moore, one Mealy) synthesize and run correctly.
2. **Core engine modules (parser, validator, encoder, generator, mapper)**
   - Acceptance: automated tests cover happy-path and invalid-input scenarios.
3. **UI workflow integration**
   - Acceptance: users can define FSM without manual JSON editing.
4. **Documentation**
   - Acceptance: contributor guide and user guide are complete and review-ready.

## Measurable Success Metrics
- Functional parity for Moore and Mealy MVP flows.
- CI passing for all added tests.
- Reproducible correctness on benchmark FSM cases.
- Mentor-approved milestone demos.

## Proposed 175-Hour Allocation
| Workstream | Hours | Notes |
|---|---:|---|
| Community bonding, setup, design freeze | 15 | Environment, architecture notes, schema/UX decisions |
| Parser + validator | 25 | Determinism checks, normalization, invalid input handling |
| State encoding + truth-table generation | 20 | Binary encoding and derivation pipeline |
| Equation generation (Moore + Mealy) | 30 | Next-state and output logic generation + tests |
| Circuit mapping + simulator compatibility | 30 | Gate/flip-flop mapping and load/edit compatibility |
| UI integration and workflow polish | 25 | FSM input workflow and validation UX |
| Testing and reliability hardening | 20 | Unit + integration + complexity guardrails |
| Documentation and final handoff | 10 | Contributor and user docs, final cleanup |
| **Total** | **175** |  |

## Community Engagement and Prior Contributions
### Contribution Plan Before Final Proposal
- Submit 3-5 high-quality PRs.
- Target 1-2 merges before final selection.
- Ensure at least one PR includes meaningful tests.
- Ensure at least one PR maps directly to Project 3 groundwork.

### Contribution Themes
- Codebase familiarization (bug fixes, test improvements, low-risk refactors).
- FSM-adjacent foundations (normalization helpers, validation scaffolding, fixtures).
- Documentation improvements (simulator data flow and extension points).

## Detailed Timeline (12 Weeks)

### Community Bonding (Weeks 1-2)
**Week 1: Setup and architecture mapping**
- Complete local setup and test pipeline.
- Identify integration touchpoints for simulator data flow.
- Output: setup verified, architecture notes documented, one small onboarding contribution submitted.

**Week 2: Design freeze (MVP)**
- Finalize FSM schema, module boundaries, and error-handling strategy.
- Prepare wireframes for FSM input workflow.
- Output: mentor-reviewed design document with explicit MVP boundaries.

### Coding Phase 1 (Weeks 3-6): Core Engine
**Week 3: Parser and validator**
- Implement schema parser and validation rules.
- Add deterministic transition checks and invalid-input handling.
- Output: normalized FSM model + parser tests for valid/invalid cases.

**Week 4: State encoding**
- Implement deterministic binary state assignment.
- Generate truth-table inputs for sequential logic derivation.
- Output: encoded state map and transition truth tables for benchmark cases.

**Week 5: Equation generation**
- Generate next-state and output equations for Moore/Mealy variants.
- Add unit tests with known expected outputs.
- Output: equation generator passing benchmark validation tests.

**Week 6: Circuit mapping**
- Translate equations into CircuitVerse gate + flip-flop structures.
- Produce synthesis output compatible with simulator load/edit flow.
- Output: synthesized circuits open and execute in simulator tests.

### Midterm (Week 7)
**MVP demonstration**
- End-to-end flow: define FSM → validate → synthesize → run circuit.
- Minimum demo coverage: one Moore and one Mealy machine.
- Midterm acceptance: mentor sign-off on functional MVP.

### Coding Phase 2 (Weeks 8-11): Productization
**Week 8: UI integration**
- Build FSM input UI and connect validation feedback.
- Improve form UX and error clarity.
- Output: no manual JSON required for typical FSM input.

**Week 9: Integration hardening and layout baseline**
- Connect UI to synthesis pipeline reliably.
- Improve generated placement/wiring readability.
- Output: stable end-to-end flow with readable baseline circuit output.

**Week 10: Feature completion**
- Stabilize Moore/Mealy parity across edge cases.
- Optional controlled-scope enhancement: one-hot encoding mode.
- Output: machine-mode parity verified by tests and demos.

**Week 11: Test and reliability pass**
- Expand unit and integration coverage.
- Add safeguards for malformed input and complexity limits.
- Output: CI-green branch with documented test strategy.

### Finalization (Week 12)
**Documentation and handoff**
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

## Validation Strategy
- **Module tests:** parser, validator, encoder, and equation generation tested with fixed FSM fixtures.
- **Integration tests:** end-to-end flow from FSM input to runnable synthesized circuit.
- **Regression checks:** benchmark FSM cases retained in test suite to prevent functional drift.
- **Review checkpoints:** mentor demo at each milestone with explicit go/no-go criteria.

## Risks and Mitigation
### 1) Scope Creep Across UI and Engine
- Mitigation: lock MVP to tabular input + robust synthesis pipeline; keep visual editor enhancements as stretch goals.

### 2) Algorithmic Complexity for Larger FSM Inputs
- Mitigation: define practical limits, add complexity guards, prioritize correctness first.

### 3) Integration Mismatch with Existing Simulator Data Flow
- Mitigation: reuse current serialization patterns, validate against real fixtures, add end-to-end tests.

### 4) Product Ambiguity (UX and Modeling Decisions)
- Mitigation: freeze schema by Week 2, maintain weekly decision checkpoints with mentors.

### 5) Test Flakiness in UI and Graphical Flows
- Mitigation: keep core correctness in deterministic logic tests; limit visual assertions to critical outcomes.

### 6) Upstream Changes During Simulator Migration
- Mitigation: keep synthesis core modular and adapter-driven; rebase and merge frequently.

### 7) Review Bottlenecks
- Mitigation: small milestone-scoped PRs with clear validation artifacts.

## Contingency Plan
If schedule pressure increases:
1. Preserve core deliverable: correct Moore/Mealy synthesis pipeline.
2. Defer non-essential UX enhancements.
3. Prioritize tests and docs for completed modules.
4. Publish revised milestone plan early with mentor agreement.

## Communication and Reporting
- Weekly mentor update with completed work, blockers, and next goals.
- Demo checkpoints at each milestone boundary.
- Immediate escalation when scope or dependencies change.

## Why I Am a Good Fit
- Project scope aligns with my interest in digital logic and full-stack implementation.
- I am structuring execution for maintainability, testability, and incremental review.
- My pre-proposal plan prioritizes visible, relevant contributions before final submission.

## References
- CircuitVerse GSoC 2026 Project Ideas (Project 3)
- CircuitVerse contributor and setup documentation
