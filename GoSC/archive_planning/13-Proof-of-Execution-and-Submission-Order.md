# Proof of Execution + Submission Order

## A) Completed Assets (Ready)
- Proposal master (template aligned): `GoSC/00-Master-Submission-Template-Aligned.md`
- One-page design: `GoSC/06-One-Page-Design.md`
- Weekly lock-in plan: `GoSC/05-This-Week-Lock-In-Plan.md`
- Mentor outreach drafts: `GoSC/07-Mentor-Outreach-and-PR-Plan.md`
- PR candidate backlog: `GoSC/08-PR-Candidate-Backlog.md`
- PR command split guide: `GoSC/10-PR-Execution-Commands.md`
- PR descriptions: `GoSC/11-PR-Descriptions.md`
- Deadline tracker: `GoSC/12-Selection-Deadline-Tracker.md`

## B) Working POC Evidence
POC files:
- `GoSC/poc/fsm_poc.js`
- `GoSC/poc/poc_check.js`
- `GoSC/poc/examples/moore_3state.json`
- `GoSC/poc/examples/mealy_4state.json`

Validated command:
```powershell
node .\GoSC\poc\poc_check.js
```
Result:
- Moore sample: PASS
- Mealy sample: PASS
- Final assertion line: `POC checks passed.`

## C) Code Changes Prepared for PRs
- `app/controllers/api/v1/projects_controller.rb`
  - corrected `unavailable` typo in `circuit_data` error response
  - removed redundant duplicate `update!` call in update endpoint
- `spec/requests/api/v1/projects_controller/circuit_data_spec.rb`
  - updated expected not-found message text

## D) Targeted Test Validation Completed
Commands executed successfully (exit code 0):
```powershell
.\bin\bundle exec rspec spec/requests/api/v1/projects_controller/circuit_data_spec.rb
.\bin\bundle exec rspec spec/requests/api/v1/projects_controller/update_spec.rb
```

## E) Exact Submission / Outreach Order (Do in sequence)
1. Fill personal placeholders in `GoSC/00-Master-Submission-Template-Aligned.md`.
2. Run PR split flow from `GoSC/10-PR-Execution-Commands.md`.
3. Open PR #1 and PR #2 using text from `GoSC/11-PR-Descriptions.md`.
4. Post mentor message (Slack short version) from `GoSC/07-Mentor-Outreach-and-PR-Plan.md`.
5. Open GitHub Discussion draft from same file and include:
   - design link,
   - timeline link,
   - POC link,
   - PR links.
6. Post weekly status update using the template in `GoSC/07-Mentor-Outreach-and-PR-Plan.md`.

## F) Non-Negotiables for Selection Strength
- Keep PRs small and single-purpose.
- Include test evidence in every PR.
- Respond to review feedback within 24 hours.
- Do not expand scope beyond MVP without mentor confirmation.
