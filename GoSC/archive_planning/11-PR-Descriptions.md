# PR Descriptions (Copy-Paste)

## PR #1
### Title
fix(api): correct circuit_data unavailable error message

### Body
Fixes a typo in the API `circuit_data` not-found error response and updates its request spec.

#### What changed
- Updated not-found error message in `Api::V1::ProjectsController#circuit_data`
- Updated request spec expectation in `spec/requests/api/v1/projects_controller/circuit_data_spec.rb`

#### Why
- Improves API response quality and consistency for clients.
- Prevents typo propagation to downstream UI/API consumers.

#### Validation
- Request spec updated to match corrected response text.
- No functional behavior change except corrected message wording.

---

## PR #2
### Title
refactor(api): remove duplicate update call in projects endpoint

### Body
Removes a redundant duplicate update invocation in `Api::V1::ProjectsController#update`.

#### What changed
- Deleted unnecessary `@project.update!(project_params)` call before the existing conditional `@project.update(project_params)`.

#### Why
- Avoids duplicate write path in a single request.
- Keeps endpoint flow cleaner and easier to reason about.

#### Validation
- Existing request coverage for update endpoint remains applicable.
- Response behavior remains unchanged for successful updates.
