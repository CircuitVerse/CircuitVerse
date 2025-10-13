# frozen_string_literal: true

class ForumThreadNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications
  deliver_by :slack, format: :slack_message, url: :slack_webhook_url

  def message
    user = params[:user]
    thread = params[:forum_thread]
    t("users.notifications.forum_thread_notification", user: user.name, thread: thread.title.truncate_words(4))
  end

  def icon
    "far fa-comments"
  end

  def slack_message
    {
      text: "*New Forum Thread Notification*\n<#{generate_forum_thread_link(params[:forum_thread])}|#{params[:forum_thread].title}> *by*: #{params[:user].name}"
    }
  end

  def slack_webhook_url
    ENV.fetch("SLACK_NOTIFY_HOOK_URL", nil)
  end

  private

    def generate_forum_thread_link(forum_thread)
      "https://circuitverse.org/forum/threads/#{forum_thread.slug}"
    end
end
