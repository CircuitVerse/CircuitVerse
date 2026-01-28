# Logix Admin Dashboard Migration Guide: RailsAdmin to Avo

## Overview

This guide outlines the migration from RailsAdmin to Avo for Logix's admin dashboard. The work is structured to be divided between two developers for efficient parallel development.

## Current State Analysis

The current admin implementation uses:

- **RailsAdmin gem** (`rails_admin >= 3.0.0.rc3, < 4`) mounted at `/admin`
- **Authorization**: Simple admin check via `current_user.admin?`
- **Policy System**: Pundit policies for authorization
- **Admin Controllers**: Limited custom admin controllers (contests only)

## Migration Strategy

### Phase 1: Setup and Core Models (Developer A)

**Estimated Time**: 4-5 days

#### 1.1 Initial Setup

```bash
# Add Avo to Gemfile
echo 'gem "avo", "~> 3.0"' >> Gemfile
bundle install

# Generate Avo configuration
rails generate avo:install
```

#### 1.2 Authentication & Authorization Setup

Create/update `app/avo/concerns/authentication.rb`:

```ruby
module Avo
  module Authentication
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_admin!
    end

    private

    def authenticate_admin!
      redirect_to root_path unless current_user&.admin?
    end

    def current_user_method
      :current_user
    end
  end
end
```

#### 1.3 Core User Management Resources

**File**: `app/avo/resources/user_resource.rb`

```ruby
class Avo::Resources::UserResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search = {
    query: -> { query.ransack(name_cont: params[:q], email_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id, link_to_resource: true
    field :name, as: :text, required: true
    field :email, as: :text, required: true
    field :admin, as: :boolean
    field :confirmed_at, as: :date_time, readonly: true
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    # Associations
    field :projects, as: :has_many
    field :groups_owned, as: :has_many, through: :primary_mentor
    field :group_members, as: :has_many
  end

  def filters
    filter AdminUserFilter
    filter CreatedDateFilter
  end

  def actions
    action ToggleAdminAction
    action SendWelcomeEmailAction
  end
end
```

#### 1.4 Project Management Resources

**File**: `app/avo/resources/project_resource.rb`

```ruby
class Avo::Resources::ProjectResource < Avo::BaseResource
  self.title = :name
  self.includes = [:author, :assignment, :forked_project, :tags]
  self.search = {
    query: -> { query.ransack(name_cont: params[:q], description_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id, link_to_resource: true
    field :name, as: :text, required: true, link_to_resource: true
    field :description, as: :textarea
    field :project_access_type, as: :select,
          options: ["Public", "Private", "Limited Access"]
    field :author, as: :belongs_to, searchable: true
    field :assignment, as: :belongs_to
    field :forked_project, as: :belongs_to

    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true
    field :view_count, as: :number, readonly: true
    field :stars_count, as: :number, readonly: true

    # File attachments
    field :image_preview, as: :file, accept: "image/*"
    field :circuit_preview, as: :file

    # Associations
    field :collaborations, as: :has_many
    field :tags, as: :has_many
    field :stars, as: :has_many
    field :forks, as: :has_many, readonly: true
  end

  def filters
    filter ProjectAccessFilter
    filter AuthorFilter
    filter TagsFilter
    filter CreatedDateFilter
  end

  def actions
    action FeatureProjectAction
    action DuplicateProjectAction
    action ExportProjectAction
  end
end
```

### Phase 2: Educational Features (Developer B)

**Estimated Time**: 4-5 days

#### 2.1 Group Management Resources

**File**: `app/avo/resources/group_resource.rb`

```ruby
class Avo::Resources::GroupResource < Avo::BaseResource
  self.title = :name
  self.includes = [:primary_mentor, :group_members, :assignments]

  def fields
    field :id, as: :id, link_to_resource: true
    field :name, as: :text, required: true
    field :primary_mentor, as: :belongs_to, searchable: true
    field :group_token, as: :text, readonly: true, hide_on: [:index]
    field :token_expires_at, as: :date_time, readonly: true

    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    # Associations
    field :group_members, as: :has_many
    field :assignments, as: :has_many
    field :pending_invitations, as: :has_many
  end

  def filters
    filter PrimaryMentorFilter
    filter TokenExpiryFilter
    filter CreatedDateFilter
  end

  def actions
    action RegenerateTokenAction
    action ExportMembersAction
    action SendInviteEmailAction
  end
end
```

#### 2.2 Assignment Management Resources

**File**: `app/avo/resources/assignment_resource.rb`

```ruby
class Avo::Resources::AssignmentResource < Avo::BaseResource
  self.title = :name
  self.includes = [:group, :projects, :grades]

  def fields
    field :id, as: :id, link_to_resource: true
    field :name, as: :text, required: true
    field :description, as: :textarea
    field :group, as: :belongs_to, required: true, searchable: true
    field :deadline, as: :date_time, required: true
    field :grading_scale, as: :select,
          options: { "No Scale" => "no_scale", "Letter" => "letter",
                    "Percent" => "percent", "Custom" => "custom" }
    field :status, as: :select,
          options: { "Open" => "open", "Closed" => "closed" }

    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    # Associations
    field :projects, as: :has_many
    field :grades, as: :has_many
  end

  def filters
    filter GroupFilter
    filter DeadlineFilter
    filter GradingScaleFilter
    filter StatusFilter
  end

  def actions
    action CloseAssignmentAction
    action ReopenAssignmentAction
    action ExportGradesAction
  end
end
```

#### 2.3 Contest Management Resources

**File**: `app/avo/resources/contest_resource.rb`

```ruby
class Avo::Resources::ContestResource < Avo::BaseResource
  self.title = :name
  self.includes = [:submissions, :contest_winner]

  def fields
    field :id, as: :id, link_to_resource: true
    field :name, as: :text, required: true
    field :description, as: :textarea
    field :deadline, as: :date_time, required: true
    field :status, as: :select, options: { "Live" => "live", "Completed" => "completed" }

    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    # Associations
    field :submissions, as: :has_many, readonly: true
    field :submission_votes, as: :has_many, readonly: true
    field :contest_winner, as: :has_one
  end

  def filters
    filter ContestStatusFilter
    filter DeadlineFilter
  end

  def actions
    action CompleteContestAction
    action AnnounceWinnerAction
    action ExportSubmissionsAction
  end
end
```

### Phase 3: System Management (Developer A continues)

**Estimated Time**: 2-3 days

#### 3.1 Announcement Management

**File**: `app/avo/resources/announcement_resource.rb`

```ruby
class Avo::Resources::AnnouncementResource < Avo::BaseResource
  self.title = :body
  self.includes = []

  def fields
    field :id, as: :id, link_to_resource: true
    field :body, as: :textarea, required: true
    field :link, as: :text
    field :start_date, as: :date_time
    field :end_date, as: :date_time

    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true
  end

  def filters
    filter ActiveAnnouncementsFilter
    filter DateRangeFilter
  end

  def actions
    action PublishAnnouncementAction
    action ScheduleAnnouncementAction
  end
end
```

#### 3.2 Analytics and Monitoring Resources

**File**: `app/avo/resources/featured_circuit_resource.rb`

```ruby
class Avo::Resources::FeaturedCircuitResource < Avo::BaseResource
  self.title = :id
  self.includes = [:project]

  def fields
    field :id, as: :id, link_to_resource: true
    field :project, as: :belongs_to, required: true, searchable: true
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true
  end

  def actions
    action RemoveFromFeaturedAction
  end
end
```

### Phase 4: Custom Actions and Filters (Developer B continues)

**Estimated Time**: 2-3 days

#### 4.1 Custom Actions

**File**: `app/avo/actions/toggle_admin_action.rb`

```ruby
class Avo::Actions::ToggleAdminAction < Avo::BaseAction
  self.name = "Toggle Admin Status"
  self.message = "Are you sure you want to toggle admin status for these users?"
  self.confirm_button_label = "Toggle Admin"

  def handle(records:, fields:, current_user:, resource:, **args)
    records.each do |user|
      user.update!(admin: !user.admin?)
    end

    succeed "Admin status toggled for #{records.count} user(s)"
  end
end
```

**File**: `app/avo/actions/feature_project_action.rb`

```ruby
class Avo::Actions::FeatureProjectAction < Avo::BaseAction
  self.name = "Feature/Unfeature Project"
  self.message = "Toggle featured status for selected projects"

  def handle(records:, fields:, current_user:, resource:, **args)
    records.each do |project|
      if project.featured_circuit
        project.featured_circuit.destroy!
      else
        FeaturedCircuit.create!(project: project)
      end
    end

    succeed "Featured status toggled for #{records.count} project(s)"
  end
end
```

#### 4.2 Custom Filters

**File**: `app/avo/filters/admin_user_filter.rb`

```ruby
class Avo::Filters::AdminUserFilter < Avo::Filters::BooleanFilter
  self.name = "Admin Users"

  def apply(request, query, values)
    return query unless values["admin_users"]

    query.where(admin: true)
  end

  def options
    {
      admin_users: "Show only admin users"
    }
  end
end
```

**File**: `app/avo/filters/project_access_filter.rb`

```ruby
class Avo::Filters::ProjectAccessFilter < Avo::Filters::SelectFilter
  self.name = "Project Access"

  def apply(request, query, value)
    case value
    when "public"
      query.where(project_access_type: "Public")
    when "private"
      query.where(project_access_type: "Private")
    when "limited"
      query.where(project_access_type: "Limited Access")
    else
      query
    end
  end

  def options
    {
      public: "Public",
      private: "Private",
      limited: "Limited Access"
    }
  end
end
```

### Phase 5: Advanced Features and Polish (Both developers)

**Estimated Time**: 3-4 days

#### 5.1 Dashboard Customization

**File**: `app/avo/dashboards/main_dashboard.rb`

```ruby
class Avo::Dashboards::MainDashboard < Avo::BaseDashboard
  self.id = "main_dashboard"
  self.name = "CircuitVerse Admin"
  self.description = "CircuitVerse administrative dashboard"

  def cards
    card UserStatsCard
    card ProjectStatsCard
    card SystemHealthCard
    card RecentActivityCard
  end
end
```

#### 5.2 Metrics and Cards

**File**: `app/avo/cards/user_stats_card.rb`

```ruby
class Avo::Cards::UserStatsCard < Avo::Cards::MetricCard
  self.id = "user_stats"
  self.label = "User Statistics"

  def query
    result.title("Total Users").value(User.count)
    result.title("Admin Users").value(User.where(admin: true).count)
    result.title("New Users (30 days)").value(User.where(created_at: 30.days.ago..)).count
  end
end
```

**File**: `app/avo/cards/project_stats_card.rb`

```ruby
class Avo::Cards::ProjectStatsCard < Avo::Cards::MetricCard
  self.id = "project_stats"
  self.label = "Project Statistics"

  def query
    result.title("Total Projects").value(Project.count)
    result.title("Public Projects").value(Project.where(project_access_type: "Public").count)
    result.title("Featured Projects").value(FeaturedCircuit.count)
  end
end
```

#### 5.3 Tools and Utilities

**File**: `app/avo/tools/system_maintenance_tool.rb`

```ruby
class Avo::Tools::SystemMaintenanceTool < Avo::BaseTool
  self.id = "system_maintenance"
  self.name = "System Maintenance"

  def authorize(user:)
    user.admin?
  end

  def options
    {
      clear_cache: "Clear Application Cache",
      cleanup_temp_files: "Cleanup Temporary Files",
      optimize_database: "Optimize Database"
    }
  end
end
```

## Configuration Files

### Main Avo Configuration

**File**: `config/initializers/avo.rb`

```ruby
Avo.configure do |config|
  config.app_name = "CircuitVerse Admin"
  config.license = "community" # or your license key
  config.root_path = "/admin"

  # Authentication
  config.current_user_method = :current_user
  config.authenticate = :authenticate_admin!
  config.authorization_methods = {
    index: :avo_index?,
    show: :avo_show?,
    edit: :avo_edit?,
    new: :avo_new?,
    update: :avo_update?,
    create: :avo_create?,
    destroy: :avo_destroy?
  }

  # UI Configuration
  config.primary_color = "#43b984" # CircuitVerse brand color
  config.timezone = "UTC"
  config.per_page = 20
  config.per_page_steps = [10, 20, 50, 100]

  # Features
  config.search_debounce = 300
  config.view_component_path = "app/views/avo"
end
```

### Routes Configuration

**File**: Add to `config/routes.rb`

```ruby
# Replace the existing RailsAdmin mount
# mount RailsAdmin::Engine => "/admin", as: "rails_admin"

# Add Avo mount
authenticate :user, ->(u) { u.admin? } do
  mount Avo::Engine, at: Avo.configuration.root_path
end
```

## Migration Steps

### Developer A Initial Commands

```bash
# 1. Setup development environment
git checkout -b feature/avo-migration-phase1
bundle install

# 2. Generate Avo installation
rails generate avo:install

# 3. Create base resources
rails generate avo:resource User
rails generate avo:resource Project
rails generate avo:resource Announcement
rails generate avo:resource FeaturedCircuit

# 4. Generate custom actions and filters
mkdir -p app/avo/actions app/avo/filters app/avo/cards app/avo/tools
```

### Developer B Initial Commands

```bash
# 1. Setup development environment
git checkout -b feature/avo-migration-phase2
git pull origin feature/avo-migration-phase1

# 2. Create educational resources
rails generate avo:resource Group
rails generate avo:resource Assignment
rails generate avo:resource Contest
rails generate avo:resource GroupMember
rails generate avo:resource Grade

# 3. Create associated filters and actions
```

## Testing Strategy

### Manual Testing Checklist

- [ ] Admin authentication works correctly
- [ ] All resources are accessible and functional
- [ ] CRUD operations work for all models
- [ ] Search functionality works across resources
- [ ] Filters are working as expected
- [ ] Custom actions execute successfully
- [ ] Authorization policies are enforced
- [ ] Dashboard displays correct metrics

### Automated Testing

```ruby
# spec/system/admin/avo_spec.rb
require 'rails_helper'

RSpec.describe "Avo Admin Interface", type: :system do
  let(:admin_user) { create(:user, admin: true) }
  let(:regular_user) { create(:user, admin: false) }

  context "with admin user" do
    before { login_as(admin_user, scope: :user) }

    it "allows access to admin dashboard" do
      visit "/admin"
      expect(page).to have_content("Logix Admin")
    end

    it "allows managing users" do
      visit "/admin/resources/users"
      expect(page).to have_content("Users")
      # Add more specific tests
    end
  end

  context "with regular user" do
    before { login_as(regular_user, scope: :user) }

    it "redirects to root path" do
      visit "/admin"
      expect(current_path).to eq(root_path)
    end
  end
end
```

## Deployment Considerations

### Environment Variables

```env
# Add to .env files
AVO_LICENSE_KEY=your_license_key_here (if using pro version)
```

### Database Migrations

No additional migrations required as Avo uses existing models.

### Asset Compilation

```bash
# Ensure assets are compiled in production
RAILS_ENV=production rails assets:precompile
```

## Cleanup Tasks

### Remove RailsAdmin

```ruby
# 1. Remove from Gemfile
# gem "rails_admin", [">= 3.0.0.rc3", "< 4"]

# 2. Remove initializer
rm config/initializers/rails_admin.rb

# 3. Update routes.rb (remove RailsAdmin mount)

# 4. Run bundle install to remove the gem
bundle install
```

### Update Documentation

- [ ] Update README with new admin access instructions
- [ ] Create admin user guide
- [ ] Update deployment documentation

## Work Distribution Summary

### Developer A Responsibilities (8-9 days total)

1. **Setup Phase** (2 days): Avo installation, configuration, authentication
2. **Core Models** (3 days): User and Project resources with full functionality
3. **System Management** (2 days): Announcements, featured circuits, analytics
4. **Polish Phase** (2 days): Dashboard customization, testing, documentation

### Developer B Responsibilities (8-9 days total)

1. **Educational Features** (4 days): Groups, assignments, contests management
2. **Actions & Filters** (2 days): Custom actions and filters for educational resources
3. **Advanced Features** (2 days): Metrics cards, tools, utilities
4. **Testing & Polish** (1 day): System testing, bug fixes

## Migration Timeline

| Week   | Developer A                    | Developer B                                 |
| ------ | ------------------------------ | ------------------------------------------- |
| Week 1 | Setup + User/Project Resources | Educational Resources (Groups, Assignments) |
| Week 2 | System Management + Dashboard  | Actions, Filters + Contest Management       |
| Week 3 | Testing + Documentation        | Testing + Advanced Features                 |

## Success Metrics

- [ ] 100% feature parity with current RailsAdmin setup
- [ ] Improved UI/UX for administrators
- [ ] Better performance (aim for <2s page load times)
- [ ] Mobile-responsive admin interface
- [ ] Comprehensive test coverage (>80%)
- [ ] Zero downtime deployment

This migration will modernize Logix's admin interface while maintaining all existing functionality and improving the overall administrator experience.
