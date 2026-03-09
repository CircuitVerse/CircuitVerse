# Project 3 Proposal: FSM to Circuit Synthesizer

## Candidate
- Name: Umair
- Program: Google Summer of Code 2026
- Organization: CircuitVerse
- Project: FSM to Circuit Synthesizer (Project 3)
- Duration: 175 hours

## Abstract
Finite State Machines are a core topic in digital logic, but learners often struggle to manually convert state behavior into gate-level circuits. CircuitVerse currently provides strong circuit-building tools, yet it lacks an end-to-end FSM workflow.

This proposal introduces an FSM-to-circuit synthesizer that lets users define Moore or Mealy machines and automatically generate equivalent, editable CircuitVerse circuits.

## Problem and Motivation
- Students and educators spend significant time translating state tables/diagrams into sequential logic manually.
- Manual conversion creates frequent correctness errors in state encoding, transition logic, and output logic.
- CircuitVerse can become more educationally effective by automating this conversion while keeping results transparent and editable.

## Project Objectives
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

## Technical Plan
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
| Workstream | Hours |
|---|---:|
| Setup, architecture mapping, and design freeze | 15 |
| Parser and validator | 25 |
| State encoding and truth-table generation | 20 |
| Equation generation (Moore + Mealy) | 30 |
| Circuit mapping and simulator compatibility | 30 |
| UI integration and workflow polish | 25 |
| Testing and reliability hardening | 20 |
| Documentation and final handoff | 10 |
| **Total** | **175** |

## Validation Strategy
- Unit tests for parser, validator, encoder, and equation generator modules.
- Integration tests for end-to-end synthesis flow from FSM definition to runnable circuit.
- Benchmark FSM fixtures retained for regression protection.
- Milestone demos with mentor sign-off criteria.

## Community and Execution Plan
- Weekly progress updates with concrete blockers and next steps.
- Small, reviewable PR slices aligned to milestone boundaries.
- Midpoint and final demos with implementation notes.

## Stretch Goals
- One-hot encoding option.
- Improved baseline auto-layout for readability.
- FSM specification import/export helpers.
