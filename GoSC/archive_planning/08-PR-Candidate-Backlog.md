# PR Candidate Backlog (Codebase-Backed)

This list is curated for fast, mergeable contributions that align with Project 3 themes: validation, deterministic behavior, simulator/project data flow, and reliability.

## Already Prepared in Workspace (Ready to PR)

### PR-1: Fix API typo in `circuit_data` error message + spec sync
- Files:
  - `app/controllers/api/v1/projects_controller.rb`
  - `spec/requests/api/v1/projects_controller/circuit_data_spec.rb`
- Change:
  - Corrects user-facing error text from `unavailabe` to `unavailable`.
  - Updates matching request spec expectation.
- Why it helps:
  - Improves API quality and avoids propagating typo to client/UI consumers.
- Test impact:
  - Existing request spec updated and remains focused.

### PR-2: Remove redundant double-update in `Api::V1::ProjectsController#update`
- File:
  - `app/controllers/api/v1/projects_controller.rb`
- Change:
  - Removes unnecessary `@project.update!(project_params)` before the conditional `@project.update(project_params)`.
- Why it helps:
  - Avoids duplicate DB write and keeps update flow cleaner.
- Suggested extra test (optional before PR):
  - Add a request spec context verifying invalid update returns expected JSON API error shape without redundant side effects.

## Next High-Value Small PRs

### PR-3: Remove duplicate `Rack::Attack` middleware registration
- File:
  - `config/application.rb`
- Issue:
  - `config.middleware.use Rack::Attack` appears twice.
- Change:
  - Keep a single registration.
- Why it helps:
  - Prevents duplicate middleware stack insertion and improves config clarity.

### PR-4: Add/expand `verilog_cv` edge-case request specs
- Files:
  - `app/controllers/simulator_controller.rb`
  - `spec/requests/api/v1/simulator_controller/verilog_cv_spec.rb` (existing)
- Scope:
  - Add coverage for max payload check (`MAX_CODE_SIZE`) and timeout/error responses.
- Why it helps:
  - Strengthens reliability around synthesis endpoints.

### PR-5: Harden `image_preview` behavior when preview asset is absent
- Files:
  - `app/controllers/api/v1/projects_controller.rb`
  - `spec/requests/api/v1/projects_controller/image_preview_spec.rb`
- Potential issue:
  - `@project.image_preview.url` assumptions may be brittle for edge cases.
- Change:
  - Ensure stable fallback behavior and add test for no-preview scenario.

### PR-6: Add regression test around project slug regeneration query path
- Files:
  - `app/models/project.rb`
  - `spec/models/project_spec.rb` (if present; otherwise create targeted model spec)
- Issue:
  - Existing `FIXME` near slug query suggests known data edge-case behavior.
- Change:
  - Add regression guard test documenting current expected behavior.

## Suggested PR Sequence (This Week)
1. Open PR-1 immediately (small + clean).
2. Open PR-2 immediately after PR-1.
3. Open PR-3 if you need a quick third PR.
4. Start PR-4 only after mentor feedback (slightly deeper test work).

## PR Template Notes
For each PR, include:
- exact problem statement,
- why the change is safe,
- before/after behavior,
- tests added/updated,
- edge cases considered.
