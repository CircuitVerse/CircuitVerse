# frozen_string_literal: true

class Avo::Cards::ModelOverview < Avo::Cards::MetricCard
  self.id = "model_overview"
  self.label = "Model Overview"
  self.cols = 1
  self.rows = 1
  self.display_header = true

  # rubocop:disable Metrics/MethodLength
  def query
    models_data = [
      { name: "Users", model: User, path: "/admin2/resources/users" },
      { name: "Projects", model: Project, path: "/admin2/resources/projects" },
      { name: "Groups", model: Group, path: "/admin2/resources/groups" },
      { name: "Group Members", model: GroupMember, path: "/admin2/resources/group_members" },
      { name: "Assignments", model: Assignment, path: "/admin2/resources/assignments" },
      { name: "Grades", model: Grade, path: "/admin2/resources/grades" },
      { name: "Stars", model: Star, path: "/admin2/resources/stars" },
      { name: "Collaborations", model: Collaboration, path: "/admin2/resources/collaborations" },
      { name: "Tags", model: Tag, path: "/admin2/resources/tags" },
      { name: "Taggings", model: Tagging, path: "/admin2/resources/taggings" },
      { name: "Featured Circuits", model: FeaturedCircuit, path: "/admin2/resources/featured_circuits" },
      { name: "Announcements", model: Announcement, path: "/admin2/resources/announcements" },
      { name: "Custom Mails", model: CustomMail, path: "/admin2/resources/custom_mails" },
      { name: "Pending Invitations", model: PendingInvitation, path: "/admin2/resources/pending_invitations" },
      { name: "Push Subscriptions", model: PushSubscription, path: "/admin2/resources/push_subscriptions" },
      { name: "Project Data", model: ProjectDatum, path: "/admin2/resources/project_data" },
      { name: "Contests", model: Contest, path: "/admin2/resources/contests" },
      { name: "Contest Winners", model: ContestWinner, path: "/admin2/resources/contest_winners" },
      { name: "Submissions", model: Submission, path: "/admin2/resources/submissions" },
      { name: "Submission Votes", model: SubmissionVote, path: "/admin2/resources/submission_votes" },
      { name: "Forum Categories", model: ForumCategory, path: "/admin2/resources/forum_categories" },
      { name: "Forum Threads", model: ForumThread, path: "/admin2/resources/forum_threads" },
      { name: "Forum Posts", model: ForumPost, path: "/admin2/resources/forum_posts" },
      { name: "Forum Subscriptions", model: ForumSubscription, path: "/admin2/resources/forum_subscriptions" },
      { name: "Comments", model: Commontator::Comment, path: "/admin2/resources/comments" },
      { name: "Threads", model: Commontator::Thread, path: "/admin2/resources/threads" },
      { name: "Subscriptions", model: Commontator::Subscription, path: "/admin2/resources/subscriptions" },
      { name: "Issue Circuit Data", model: IssueCircuitDatum, path: "/admin2/resources/issue_circuit_data" },
      { name: "Noticed Notifications", model: NoticedNotification, path: "/admin2/resources/noticed_notifications" },
      { name: "ActiveStorage Attachments", model: ActiveStorage::Attachment,
        path: "/admin2/resources/active_storage_attachments" },
      { name: "ActiveStorage Blobs", model: ActiveStorage::Blob, path: "/admin2/resources/active_storage_blobs" },
      { name: "ActiveStorage Variant Records", model: ActiveStorage::VariantRecord,
        path: "/admin2/resources/active_storage_variant_records" },
      { name: "Ahoy Visits", model: Ahoy::Visit, path: "/admin2/resources/ahoy_visits" },
      { name: "Ahoy Events", model: Ahoy::Event, path: "/admin2/resources/ahoy_events" },
      { name: "Mailkick Opt Outs", model: Mailkick::OptOut, path: "/admin2/resources/mailkick_opt_outs" },
      { name: "Maintenance Tasks Runs", model: MaintenanceTasks::Run, path: "/admin2/resources/maintenance_tasks_runs" }
    ]

    result do
      models_data.map do |data|
        {
          name: data[:name],
          count: data[:model].count,
          last_created: data[:model].maximum(:created_at)&.strftime("%B %d, %Y %H:%M"),
          path: data[:path]
        }
      rescue StandardError
        {
          name: data[:name],
          count: 0,
          last_created: "N/A",
          path: data[:path]
        }
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
end
