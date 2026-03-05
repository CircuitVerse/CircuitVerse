# PR Execution Commands (Exact, Copy-Paste)

These commands split your current working changes into two clean PRs.

## 0) Safety checkpoint (optional)
```powershell
git stash push -m "backup-before-pr-split"
git stash pop
```

## 1) PR #1 branch: typo fix + spec sync
```powershell
git checkout -b fix/api-circuit-data-unavailable-typo
```

Stage only these files for PR #1:
```powershell
git add app/controllers/api/v1/projects_controller.rb spec/requests/api/v1/projects_controller/circuit_data_spec.rb
```

If both controller hunks are staged, unstage and stage only the typo hunk:
```powershell
git reset app/controllers/api/v1/projects_controller.rb
git add -p app/controllers/api/v1/projects_controller.rb
```
Choose `y` only for the hunk that changes `unavailabe` -> `unavailable`, and `n` for the redundant update hunk.

Commit:
```powershell
git commit -m "fix(api): correct circuit_data unavailable error message"
```

Push:
```powershell
git push -u origin fix/api-circuit-data-unavailable-typo
```

## 2) PR #2 branch: remove redundant update
Switch back and create second branch from updated main/master:
```powershell
git checkout master
git pull upstream master
git checkout -b refactor/api-remove-duplicate-project-update
```

Stage only redundant update hunk:
```powershell
git add -p app/controllers/api/v1/projects_controller.rb
```
Choose `y` only for removing `@project.update!(project_params)`.

Commit:
```powershell
git commit -m "refactor(api): remove duplicate update call in projects endpoint"
```

Push:
```powershell
git push -u origin refactor/api-remove-duplicate-project-update
```

## 3) Keep GoSC docs out of these PRs
Do not stage `GoSC/` files in these code PRs.

If accidentally staged:
```powershell
git restore --staged GoSC
```

## 4) Open PRs
- PR #1 base: `CircuitVerse/master`
- PR #2 base: `CircuitVerse/master`

Use PR descriptions from `GoSC/11-PR-Descriptions.md`.
