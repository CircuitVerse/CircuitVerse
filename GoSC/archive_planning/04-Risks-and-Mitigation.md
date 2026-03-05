# Risks and Mitigation (Project 3)

## Risk Management Approach
- Review risks weekly with mentors.
- Re-rank risks by likelihood and impact every milestone.
- Apply scope control early instead of late-stage compression.

## 1) Scope Creep Across UI and Engine
**Risk:** Building a full visual editor and synthesis engine in parallel can exceed 175-hour constraints.

**Impact:** High  
**Likelihood:** Medium

**Mitigation:**
- Lock MVP to structured/tabular FSM input plus robust synthesis pipeline.
- Treat diagram editor enhancements strictly as stretch goals.
- Require explicit mentor approval before adding non-MVP features.

## 2) Algorithmic Complexity for Larger FSM Inputs
**Risk:** Synthesis/minimization cost grows rapidly for larger state/input spaces.

**Impact:** High  
**Likelihood:** Medium

**Mitigation:**
- Set practical input limits for MVP and document them clearly.
- Add complexity guards and user-facing warnings.
- Optimize only after baseline correctness and maintainability are achieved.

## 3) Integration Mismatch with Existing Simulator Data Flow
**Risk:** Generated circuits may not fully align with simulator data conventions and expected metadata.

**Impact:** High  
**Likelihood:** Medium

**Mitigation:**
- Reuse established save/load and serialization patterns.
- Validate output against real fixtures sampled from current project data.
- Add end-to-end tests from FSM input to runnable synthesized circuit.

## 4) Product Ambiguity (UX and Modeling Decisions)
**Risk:** Late changes in FSM input UX or modeling assumptions can trigger rework.

**Impact:** Medium  
**Likelihood:** Medium

**Mitigation:**
- Freeze schema and interaction model by end of Week 2.
- Run weekly mentor checkpoints with concrete demos and decision logs.
- Capture assumptions and non-goals in the design document.

## 5) Test Flakiness in UI and Graphical Flows
**Risk:** Graphical assertions can be brittle and reduce confidence in CI.

**Impact:** Medium  
**Likelihood:** Medium

**Mitigation:**
- Keep most correctness checks in deterministic logic-layer tests.
- Use fixed fixtures for integration tests.
- Limit visual checks to key outcomes rather than pixel-level behavior.

## 6) Upstream Changes During Simulator Migration
**Risk:** Ongoing simulator/frontend migration may shift integration boundaries during implementation.

**Impact:** Medium  
**Likelihood:** Medium

**Mitigation:**
- Keep synthesis core modular and adapter-driven.
- Isolate UI integration from core synthesis logic.
- Rebase frequently and merge incrementally to reduce drift.

## 7) Review Bottlenecks
**Risk:** Large or unclear PRs may slow mentor feedback cycles.

**Impact:** Medium  
**Likelihood:** Medium

**Mitigation:**
- Keep PRs milestone-scoped and small.
- Include reproduction, test evidence, and design notes in each PR.
- Share design drafts before implementation-heavy weeks.

## Contingency Plan
If schedule pressure increases:
1. Preserve core deliverable: correct Moore/Mealy synthesis pipeline.
2. Defer non-essential UX enhancements to stretch scope.
3. Prioritize tests and documentation for completed modules.
4. Publish revised milestone plan immediately with mentor agreement.
