# GSoC 2026 Audit & Scaffold Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix two minor gaps (group policy `show?` and assignment form `submission_type`), add child-group rendering to the group show page, and append GSoC demo seeds — all other deliverables already exist.

**Architecture:** Targeted edits to 4 files. No new files, migrations, or gems needed. Every deliverable audited below was found to already exist in the codebase.

**Tech Stack:** Rails 7, Pundit, Bootstrap 5, vanilla ERB, existing green `#1D9E75` button style.

---

## Audit Results (read before executing)

| Deliverable | Status | File(s) |
|---|---|---|
| Routes — assignments plural | ✅ Already correct | `config/routes.rb:37` |
| Routes — LTI `/lti` scope | ✅ Exists | `config/routes.rb:146-150` |
| Group policy `show_access?` | ✅ Allows members + admin | `app/policies/group_policy.rb:12` |
| Group policy `show?` | ⚠️ Missing — controller calls `show_access?` directly, so no bug, but should add alias | `app/policies/group_policy.rb` |
| `parent_group_id` migration | ✅ Exists | `db/migrate/20260312213705_add_parent_group_to_groups.rb` |
| Group model hierarchy | ✅ Exists | `app/models/group.rb:19-21` |
| SubgroupsController | ✅ Has create/show/destroy | `app/controllers/subgroups_controller.rb` |
| Child groups in show view | ❌ Missing | `app/views/groups/show.html.erb` |
| `submission_type` DB column | ✅ Exists | `db/schema.rb:138` |
| `submission_type` enum | ✅ `individual`/`group` | `app/models/assignment.rb:26` |
| `submission_type` in form | ❌ Missing | `app/views/assignments/_form.html.erb` |
| `submission_type` in permitted params | ❌ Missing | `app/controllers/assignments_controller.rb:172` |
| AssignmentsController actions | ✅ new/create/show/start/close/reopen | `app/controllers/assignments_controller.rb` |
| CircuitTemplate model | ✅ Exists | `app/models/circuit_template.rb` |
| Assignment.circuit_template FK | ✅ Exists | `app/models/assignment.rb:21` |
| AssignmentTestCase model | ✅ Exists | `app/models/assignment_test_case.rb` |
| Assignment.has_many :assignment_test_cases | ✅ Exists | `app/models/assignment.rb:22` |
| LtiController (launch/oidc_login/jwks) | ✅ Exists | `app/controllers/lti_controller.rb` |
| `ims-lti` gem | ✅ `~> 1.2, < 2.0` | `Gemfile:80` |
| GSoC demo seeds (AND Gate Lab etc.) | ✅ Exists | `db/seeds.rb:76-217` |
| CS101/TeamA/HalfAdder seeds | ❌ Missing | `db/seeds.rb` — need to append |

**Net result: 4 changes, 4 files.**

---

## Chunk 1: Group Policy — add `show?` alias

**Files:**
- Modify: `app/policies/group_policy.rb`

The controller calls `authorize @group, :show_access?` so there is no runtime bug. However `show?` should exist for completeness and in case any other controller calls `authorize @group` (which defaults to `show?`).

- [ ] **Step 1: Add `show?` to the policy**

Open `app/policies/group_policy.rb` and add immediately after the `show_access?` method:

```ruby
def show?
  show_access?
end
```

Final file should look like:

```ruby
# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  attr_reader :user, :group

  def initialize(user, group)
    @user = user
    @group = group
    @admin_access = (group.primary_mentor_id == user.id) || user.admin?
  end

  def show_access?
    @admin_access || group.group_members.exists?(user_id: user.id)
  end

  def show?
    show_access?
  end

  def admin_access?
    @admin_access
  end

  def mentor_access?
    @admin_access || @group.group_members.exists?(user_id: user.id, mentor: true)
  end
end
```

- [ ] **Step 2: Verify no test breakage (run group policy specs)**

```bash
bundle exec rspec spec/policies/group_policy_spec.rb --format documentation
```

Expected: all pass (or none exist yet — either is acceptable at this stage).

- [ ] **Step 3: Commit**

```bash
git add app/policies/group_policy.rb
git commit -m "fix: add show? alias to GroupPolicy delegating to show_access?"
```

---

## Chunk 2: Assignment form — expose `submission_type`

**Files:**
- Modify: `app/views/assignments/_form.html.erb`
- Modify: `app/controllers/assignments_controller.rb`

The `submission_type` enum (`individual: 0`, `group: 1`) exists on the model and in the DB but is not exposed in the create/edit form, and the param is not permitted.

- [ ] **Step 1: Add `submission_type` to `assignment_create_params`**

In `app/controllers/assignments_controller.rb`, change line 172:

```ruby
# BEFORE
params.expect(assignment: %i[name deadline description grading_scale
                             restrictions feature_restrictions])

# AFTER
params.expect(assignment: %i[name deadline description grading_scale
                             restrictions feature_restrictions submission_type])
```

- [ ] **Step 2: Add the field to the form**

In `app/views/assignments/_form.html.erb`, add the following block immediately before the existing submit button `<div>` (the `<div class="field mb-3">` that contains `form.submit`):

```erb
<div id="submission-type-field" class="field mb-3">
  <h6><%= form.label :submission_type, "Submission Mode" %></h6>
  <div class="d-flex gap-3">
    <div class="form-check">
      <%= form.radio_button :submission_type, :individual, class: "form-check-input", id: "submission_individual" %>
      <%= form.label :submission_type, "Individual", value: :individual, class: "form-check-label", for: "submission_individual" %>
    </div>
    <div class="form-check">
      <%= form.radio_button :submission_type, :group, class: "form-check-input", id: "submission_group" %>
      <%= form.label :submission_type, "Group", value: :group, class: "form-check-label", for: "submission_group" %>
    </div>
  </div>
  <small class="form-text text-muted">Individual: each student submits separately. Group: one submission per subgroup.</small>
</div>
```

- [ ] **Step 3: Verify the form renders without errors**

Start the Rails server and visit `/groups/:id/assignments/new`. Confirm the "Submission Mode" radio buttons appear.

- [ ] **Step 4: Commit**

```bash
git add app/views/assignments/_form.html.erb app/controllers/assignments_controller.rb
git commit -m "feat: expose submission_type (individual/group) on assignment form"
```

---

## Chunk 3: Groups show page — render child groups

**Files:**
- Modify: `app/views/groups/show.html.erb`

The `Group` model already has `has_many :child_groups` and `belongs_to :parent_group`. The show page does not render them.

- [ ] **Step 1: Load child groups in the controller**

In `app/controllers/groups_controller.rb`, update the `show` action to eager-load child groups:

```ruby
def show
  @group_member  = @group.group_members.new
  @child_groups  = @group.child_groups.includes(:primary_mentor, :group_members)
  @group.assignments.each do |assignment|
    if (assignment.status == "reopening") && (assignment.deadline < Time.zone.now)
      assignment.status = "closed"
      assignment.save
    end
  end
end
```

- [ ] **Step 2: Add child groups section to the show view**

In `app/views/groups/show.html.erb`, add the following **before** the `<!-- Mentor Section -->` comment (i.e., after the `allowed_domain` info block, around line 37):

```erb
<!-- Child Groups / Sub-Classes Section -->
<% if @child_groups.any? %>
  <div class="d-flex justify-content-between align-items-center mb-2 mt-4">
    <h3 class="mb-0">Sub-Classes</h3>
  </div>
  <hr>
  <div class="row g-3 mb-4">
    <% @child_groups.each do |child| %>
      <div class="col-12 col-md-6 col-lg-4">
        <div class="card h-100">
          <div class="card-body">
            <h5 class="card-title"><%= child.name %></h5>
            <p class="card-text text-muted mb-1">
              <small>Mentor: <%= child.primary_mentor.name %></small>
            </p>
            <p class="card-text text-muted mb-2">
              <small><%= child.group_members.count %> member(s)</small>
            </p>
            <%= link_to "View", group_path(child), class: "btn primary-button btn-sm" %>
          </div>
        </div>
      </div>
    <% end %>
  </div>
<% end %>
```

- [ ] **Step 3: Verify no N+1 (already included above via `.includes`)**

Confirm the show page loads without errors when a group has child groups.

- [ ] **Step 4: Commit**

```bash
git add app/views/groups/show.html.erb app/controllers/groups_controller.rb
git commit -m "feat: render child groups (sub-classes) on group show page"
```

---

## Chunk 4: Seeds — append CS101 / Team A / Half Adder Lab demo data

**Files:**
- Modify: `db/seeds.rb`

The existing seeds already have extensive GSoC demo data. Append the specific data requested without touching anything above.

- [ ] **Step 1: Append to `db/seeds.rb`**

Add the following block at the very end of `db/seeds.rb`:

```ruby
# ============================================================
# GSoC 2026 Proposal Demo — Classroom Hierarchy Seeds
# ============================================================
if Rails.env.development?
  mentor = User.find_or_create_by!(email: "mentor@college.edu") do |u|
    u.name     = "Demo Mentor"
    u.password = "password123"
    u.confirmed_at = Time.zone.now
  end

  parent = Group.find_or_create_by!(name: "CS101 - Digital Design") do |g|
    g.primary_mentor = mentor
  end

  child = Group.find_or_create_by!(name: "Team A") do |g|
    g.primary_mentor = mentor
    g.parent_group   = parent
  end

  assignment = parent.assignments.find_or_create_by!(name: "Half Adder Lab") do |a|
    a.deadline    = 1.week.from_now
    a.description = "Build a half adder using XOR and AND gates"
    a.status      = "open"
  end

  puts "Seeded: Group #{parent.id}, Subgroup #{child.id}, Assignment #{assignment.id}"
end
```

- [ ] **Step 2: Run the seeds**

```bash
bundle exec rails db:seed
```

Expected output includes:
```
Seeded: Group <id>, Subgroup <id>, Assignment <id>
```

- [ ] **Step 3: Confirm no duplicate-key errors**

The `find_or_create_by!` calls are idempotent — re-running seeds should not raise errors.

- [ ] **Step 4: Commit**

```bash
git add db/seeds.rb
git commit -m "seed: append CS101 classroom hierarchy demo data for GSoC proposal"
```

---

## Final Checklist

After all chunks complete, verify the following:

- [ ] Routes fixed (assignments plural) — **Already correct, no change needed**
- [ ] Group policy fixed (members can view) — **`show_access?` already correct; `show?` alias added in Chunk 1**
- [ ] Subgroups: **existing** — `app/controllers/subgroups_controller.rb`
- [ ] Child groups in show page: **scaffolded** — Chunk 3
- [ ] Assignment `submission_type`: **existing in model/DB; exposed in form** — Chunk 2
- [ ] AssignmentTestCase model: **existing** — `app/models/assignment_test_case.rb`
- [ ] CircuitTemplate + assignment FK: **existing** — `app/models/circuit_template.rb`, `app/models/assignment.rb:21`
- [ ] LTI controller: **existing** — `app/controllers/lti_controller.rb`
- [ ] LTI routes: **existing** — `config/routes.rb:146-150`
- [ ] `ims-lti` gem: **existing** — `Gemfile:80` (`~> 1.2, < 2.0`)
- [ ] Seeds work without error — Chunk 4
