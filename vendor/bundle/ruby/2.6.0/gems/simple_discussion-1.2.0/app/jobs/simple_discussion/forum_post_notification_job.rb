class SimpleDiscussion::ForumPostNotificationJob < ApplicationJob
  include SimpleDiscussion::Engine.routes.url_helpers

  def perform(forum_post)
    send_emails(forum_post) if SimpleDiscussion.send_email_notifications
    send_webhook(forum_post) if SimpleDiscussion.send_slack_notifications
  end

  def send_emails(forum_post)
    forum_thread = forum_post.forum_thread
    users        = forum_thread.subscribed_users - [forum_post.user]
    users.each do |user|
      SimpleDiscussion::UserMailer.new_post(forum_post, user).deliver_later
    end
  end

  def send_webhook(forum_post)
    slack_webhook_url = Rails.application.secrets.simple_discussion_slack_url
    return if slack_webhook_url.blank?

    forum_thread = forum_post.forum_thread
    payload = {
      fallback: "#{forum_post.user.name} replied to <#{forum_thread_url(forum_thread, anchor: ActionView::RecordIdentifier.dom_id(forum_post))}|#{forum_thread.title}>",
      pretext: "#{forum_post.user.name} replied to <#{forum_thread_url(forum_thread, anchor: ActionView::RecordIdentifier.dom_id(forum_post))}|#{forum_thread.title}>",
      fields: [
        {
          title: "Thread",
          value: forum_thread.title,
          short: true
        },
        {
          title: "Posted By",
          value: forum_post.user.name,
          short: true,
        },
      ],
      ts: forum_post.created_at.to_i
    }

    SimpleDiscussion::Slack.new(slack_webhook_url).post(payload)
  end
end
