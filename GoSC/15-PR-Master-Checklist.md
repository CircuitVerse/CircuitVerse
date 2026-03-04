# PR Master Checklist & Submission Guide

## Current Status (March 4, 2026)

All branches are created, committed, and pushed to fork. Ready for PR submission.

---

## PR #1: Fix API Circuit Data Typo

**Status:** ✅ Already Submitted - Pending CI  
**Links:** 
- PR: https://github.com/CircuitVerse/CircuitVerse/pull/7110
- Branch: `nusRying:fix/api-circuit-data-unavailable-typo`

**What it does:**
- Fixes typo: "unavailabe" → "unavailable" in API error message
- Updates corresponding test spec
- CodeRabbit approved ✅

**Current Issue:** 
- CI blocked by workflow syntax error (being fixed below)

---

## PR #2: Refactor Duplicate Project Update

**Status:** ✅ Already Submitted - Pending CI  
**Links:**
- PR: https://github.com/CircuitVerse/CircuitVerse/pull/7111
- Branch: `nusRying:refactor/api-remove-duplicate-project-update`

**What it does:**
- Removes duplicate `@project.update!(project_params)` call
- Keeps only the conditional `@project.update(project_params)`
- Includes fix for Copilot AI comment about name sanitization
- CodeRabbit approved ✅

**Current Issue:**
- CI blocked by workflow syntax error (being fixed below)

---

## PR #3 (NEW - CRITICAL): Fix GitHub Actions Workflow

**Status:** 📝 Ready to Create  
**Target:** `CircuitVerse:master` ← `nusRying:master`

**URL to Create:**
```
https://github.com/nusRying/CircuitVerse/compare/CircuitVerse:master...nusRying:master
```

**Title:**
```
fix(ci): correct GitHub Actions workflow syntax in percy.yml
```

**Description:**
```markdown
## What changed
- Fixed invalid GitHub Actions workflow syntax in `.github/workflows/percy.yml`
- Replaced uppercase `OR`/`AND` with correct `||` and `&&` operators
- Unblocks all PR CI checks and visual regression testing

## Why
The percy.yml workflow had syntax errors preventing CI validation on any PR. 
This critical fix allows all pending PRs (#7110, #7111, #7112) to run their CI checks.

## Files changed
- `.github/workflows/percy.yml` - Fixed lines 16-20

## Testing
- Workflow file now passes GitHub Actions syntax validation
- No behavior changes, only fixing YAML operators
```

**What this fixes:**
- ✅ Unblocks #7110 CI
- ✅ Unblocks #7111 CI  
- ✅ Unblocks #7112 CI (the FSM module PR)

---

## PR #4 (NEW): FSM Synthesizer Module - Phase 1

**Status:** 📝 Ready to Create  
**Target:** `CircuitVerse:master` ← `nusRying:feat/fsm-synthesizer-phase1`

**URL to Create:**
```
https://github.com/nusRying/CircuitVerse/compare/CircuitVerse:master...nusRying:feat/fsm-synthesizer-phase1
```

**Title:**
```
feat: FSM Synthesizer Module - Phase 1 Core Engine
```

**Description:**
```markdown
## What changed
### New Services
- `FsmSynthesizer::Base` - Complete FSM data model with validation
- `FsmSynthesizer::Validator` - Determinism & completeness checks
- `FsmSynthesizer::Encoder` - Binary & one-hot state encodings
- `FsmSynthesizer::EquationGenerator` - Next-state and output logic (SOP)
- `FsmSynthesizer::CircuitMapper` - Circuit structure generation

### Tests
- Comprehensive test suite: 27+ test cases
- All core functionality covered
- Moore and Mealy machine examples

### Files Added
```
app/services/fsm_synthesizer/
├── base.rb
├── validator.rb
├── encoder.rb
├── equation_generator.rb
├── circuit_mapper.rb
└── errors.rb

spec/services/fsm_synthesizer/
├── base_spec.rb
├── validator_spec.rb
├── encoder_spec.rb
├── equation_generator_spec.rb
└── circuit_mapper_spec.rb
```

## Why
This is Phase 1 implementation of GSoC 2026 Project 3: FSM to Circuit Synthesizer

### Key achievements:
- ✅ Complete FSM data model
- ✅ Validation logic (determinism, completeness, consistency)
- ✅ State encoding strategies (binary, one-hot)
- ✅ Boolean equation generation
- ✅ Circuit mapping foundation
- ✅ Comprehensive tests

## Testing
All tests pass locally. Core engine is ready for UI integration (Phase 2).

## Related
- **GSoC 2026 Project 3 Proposal:** [GoSC/00-Master-Submission-Template-Aligned.md](../GoSC/00-Master-Submission-Template-Aligned.md)
- **Design Document:** [GoSC/06-One-Page-Design.md](../GoSC/06-One-Page-Design.md)
- **Timeline:** [GoSC/02-Timeline-and-Milestones.md](../GoSC/02-Timeline-and-Milestones.md)
- **GitHub Discussion:** [Link to discussion when available]
```

**Mark as Draft:** Yes - this PR is for planned implementation, not merge-ready yet

---

## Submission Sequence (CRITICAL ORDER)

### Step 1: Create & Merge PR #3 (Workflow Fix) 
**⚠️ DO THIS FIRST - It unblocks everything else**

1. Go to: https://github.com/nusRying/CircuitVerse/compare/CircuitVerse:master...nusRying:master
2. Copy title and description from above
3. Create Pull Request
4. **Request review** from code owners (@vedant-jain03 or maintainers)
5. **Once approved and merged**, it will automatically trigger CI on #7110 and #7111

**Expected timeline:** 1-4 hours (maintainers review PRs frequently)

---

### Step 2: Monitor PR #1 & #2 CI (Automatically triggered)
Once workflow PR merges:
- #7110 will run: lint + test checks
- #7111 will run: lint + test checks
- Both should pass ✅

**Action:** Wait for green CI checks

---

### Step 3: Create PR #4 (FSM Module)
After workflow is fixed and #7110, #7111 are green:

1. Go to: https://github.com/nusRying/CircuitVerse/compare/CircuitVerse:master...nusRying:feat/fsm-synthesizer-phase1
2. Copy title and description from above
3. Create Pull Request
4. **Mark as DRAFT** (top right corner)
5. Add to GitHub Discussion as implementation progress

---

## Summary Dashboard

| # | Title | Status | Link | Blocker |
|---|-------|--------|------|---------|
| #7110 | Fix circuit_data typo | ⏳ CI blocked | https://github.com/CircuitVerse/CircuitVerse/pull/7110 | Workflow syntax |
| #7111 | Refactor duplicate update | ⏳ CI blocked | https://github.com/CircuitVerse/CircuitVerse/pull/7111 | Workflow syntax |
| #7112 | **[CREATE]** Fix workflow | 📝 Ready | https://github.com/nusRying/CircuitVerse/compare/CircuitVerse:master...nusRying:master | None - Priority #1 |
| #7113 | **[CREATE]** FSM module | 📝 Ready | https://github.com/nusRying/CircuitVerse/compare/CircuitVerse:master...nusRying:feat/fsm-synthesizer-phase1 | None - After #7112 |

---

## Quick Copy-Paste Ready

### For PR #3 Title
```
fix(ci): correct GitHub Actions workflow syntax in percy.yml
```

### For PR #3 Description
```markdown
## What changed
- Fixed invalid GitHub Actions workflow syntax in `.github/workflows/percy.yml`
- Replaced uppercase `OR`/`AND` with correct `||` and `&&` operators
- Unblocks all PR CI checks and visual regression testing

## Why
The percy.yml workflow had syntax errors preventing CI validation on any PR. 
This critical fix allows all pending PRs (#7110, #7111, #7112) to run their CI checks.

## Files changed
- `.github/workflows/percy.yml` - Fixed lines 16-20

## Testing
- Workflow file now passes GitHub Actions syntax validation
- No behavior changes, only fixing YAML operators
```

---

## Notes

- All code is clean and tested locally ✅
- All branches are pushed to fork ✅
- Commit messages follow CircuitVerse conventions ✅
- Ready for mentor review and GSoC evaluation ✅
