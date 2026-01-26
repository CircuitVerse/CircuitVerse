# frozen_string_literal: true

class Avo::Dashboards::SiteAdministration < Avo::Dashboards::BaseDashboard
  self.id = "site_administration"
  self.name = "Site Administration"
  self.description = "Overview of all models and their record counts"
  self.grid_cols = 3
  # rubocop:disable Metrics/MethodLength

  def cards
    # Main Navigation Models
    divider label: "Navigation"

    model_card Announcement, "announcements"
    model_card Assignment, "assignments"
    model_card Collaboration, "collaborations"
    model_card Contest, "contests"
    model_card Contest::Winner, "contest_winners"
    model_card CustomMail, "custom_mails"
    model_card FeaturedCircuit, "featured_circuits"
    model_card Grade, "grades"
    model_card Group, "groups"
    model_card GroupMember, "group_members"
    model_card IssueCircuitDatum, "issue_circuit_data"
    model_card Noticed::Notification, "noticed_notifications"
    model_card PendingInvitation, "pending_invitations"
    model_card Project, "projects"
    model_card Project::ProjectDatum, "project_data"
    model_card PushSubscription, "push_subscriptions"
    model_card Star, "stars"
    model_card Submission, "submissions"
    model_card Submission::Vote, "submission_votes"
    model_card Tag, "tags"
    model_card Tagging, "taggings"
    model_card User, "users"

    # ActiveStorage
    divider label: "ActiveStorage"

    model_card ActiveStorage::Attachment, "active_storage_attachments"
    model_card ActiveStorage::Blob, "active_storage_blobs"
    model_card ActiveStorage::VariantRecord, "active_storage_variant_records"

    # Forum/Commontator
    divider label: "Forum"

    model_card ForumCategory, "forum_categories"
    model_card ForumPost, "forum_posts"
    model_card ForumSubscription, "forum_subscriptions"
    model_card ForumThread, "forum_threads"
    model_card Commontator::Comment, "comments"
    model_card Commontator::Subscription, "subscriptions"
    model_card Commontator::Thread, "threads"

    # Analytics
    divider label: "Ahoy"

    model_card Ahoy::Event, "ahoy_events"
    model_card Ahoy::Visit, "ahoy_visits"

    # Email
    divider label: "Mailkick"

    model_card Mailkick::OptOut, "mailkick_opt_outs"

    # System
    divider label: "Maintenance Tasks"

    model_card MaintenanceTasks::Run, "maintenance_tasks_runs"
  end
  # rubocop:enable Metrics/MethodLength

  private

    def model_card(model, resource_name)
      card Avo::Cards::ModelOverviewCard,
           model: model,
           label: model.model_name.human.pluralize,
           resource_path: "/admin2/resources/#{resource_name}"
    end
end
