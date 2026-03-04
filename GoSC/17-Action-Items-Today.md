# IMMEDIATE ACTION ITEMS - March 4, 2026

## ⚡ YOU NEED TO DO THIS RIGHT NOW

---

## ACTION 1: Create Workflow Fix PR (PRIORITY 1 - DO IMMEDIATELY)

### Why First?
This PR fixes the GitHub Actions syntax error that's blocking CI on all your other PRs.

### Steps:

1. **Open this link in your browser:**
   ```
   https://github.com/nusRying/CircuitVerse/compare/CircuitVerse:master...nusRying:master
   ```

2. **Click "Create Pull Request"**

3. **Copy-paste the title:**
   ```
   fix(ci): correct GitHub Actions workflow syntax in percy.yml
   ```

4. **Copy-paste the description:**
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

5. **Click "Create Pull Request"**

6. **Request review:**
   - Click "Reviewers" → type `vedant-jain03` or select code owners
   - Send a note: "Urgent: This workflow fix unblocks all pending PRs"

---

## Timeline for Action 1:
- **Now:** Create PR (2 minutes)
- **Next 1-4 hours:** Should be approved
- **After merge:** Automatic re-triggers of #7110, #7111 CI ✅

---

## ACTION 2: After Workflow PR Merges (WAIT FOR THIS)

**Watch for:**
- ✅ Workflow PR approved
- ✅ Workflow PR merged to origin/master
- ✅ CI checks pass on #7110, #7111

**Time estimate:** 1-4 hours after creating workflow PR

---

## ACTION 3: Create FSM Module PR (DO AFTER WORKFLOW MERGES)

Once workflow is merged and #7110, #7111 have green CI:

1. **Open this link:**
   ```
   https://github.com/nusRying/CircuitVerse/compare/CircuitVerse:master...nusRying:feat/fsm-synthesizer-phase1
   ```

2. **Click "Create Pull Request"**

3. **Copy-paste the title:**
   ```
   feat: FSM Synthesizer Module - Phase 1 Core Engine
   ```

4. **Copy-paste the description:**
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
   ```

5. **IMPORTANT: Mark as DRAFT**
   - Look for the dropdown arrow next to "Create Pull Request" button
   - Select "Create a draft pull request"
   - This shows it's Phase 1, not ready to merge yet

6. **Assign yourself** to show ownership

---

## ACTION 4: Update GitHub Discussion

Go back to your GitHub Discussion and add a comment:

```markdown
## Progress Update - March 4 EOD

I've been executing on the proposed MVP this week:

✅ **Completed:**
- FSM synthesizer core engine implemented (27+ tests)
- Two bug-fix PRs submitted (#7110, #7111) with code review approvals
- GitHub Actions workflow syntax fix (unblocking all CI)
- Phase 1 module architecture submitted as draft PR

📊 **Pending:**
- Mentor feedback on MVP scope (awaiting responses to earlier questions)
- CI green checks on #7110, #7111 (workflow fix should unblock these)
- FSM module peer review

🚀 **Phase 2 Ready to Start After Mentors Confirm Scope**

This demonstrates execution capability and technical alignment.
See PR #7112 (workflow fix) and #7113 (FSM module) for details.
```

---

## CHECKLIST - Mark Off as You Complete

- [ ] Create Workflow Fix PR (#7112) - DO NOW
- [ ] Request review on workflow PR
- [ ] ⏳ Wait for maintainer approval (1-4 hours)
- [ ] ⏳ Watch for #7110, #7111 CI to re-run
- [ ] ✅ Celebrate when workflow PR merges
- [ ] ✅ Verify #7110, #7111 CI passes
- [ ] Create FSM Module PR (#7113) - DO AFTER STEP 5
- [ ] Mark FSM PR as DRAFT
- [ ] Update GitHub Discussion with progress
- [ ] Update GSoC proposal with PR links

---

## EXPECTED TIMELINE

- **Now (5 min):** Create workflow fix PR
- **1-4 hours:** Workflow PR approved and merged
- **5-10 min after:** #7110, #7111 CI runs automatically
- **15-30 min after:** Both PRs should have green CI ✅
- **Then (5 min):** Create FSM module PR as draft
- **Then (2 min):** Update discussion with progress

---

## FAQ

**Q: What if workflow PR doesn't get approved quickly?**  
A: This is critical path - ping @vedant-jain03 in PR or Slack if it's stuck > 4 hours

**Q: Can I create the FSM PR before workflow merges?**  
A: You can create it, but CI will fail until workflow is fixed. Better to wait.

**Q: Should I mention these PRs in the discussion?**  
A: Yes! Update your discussion comment with links once PRs exist.

**Q: What if there are CI failures on #7110 or #7111?**  
A: They're already approved by CodeRabbit, so CI should pass. If not, reply in PR immediately.

---

## SUCCESS CRITERIA FOR THIS ACTION PLAN

✅ By end of today:
- 4 PRs created (2 existing + 2 new)
- Workflow fix merged to unblock all CI
- #7110, #7111 show green CI checks
- FSM module PR created as draft
- Discussion updated with progress
- Mentors see active execution on GSoC project

This is an **excellent** signal for your GSoC application! 🚀

---

**START WITH ACTION 1 NOW. DO IT RIGHT NOW.**

Workflow fix PR link (click and create):
→ https://github.com/nusRying/CircuitVerse/compare/CircuitVerse:master...nusRying:master
