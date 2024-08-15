module Commontator::Config
  # Attributes

  # Can be set in initializer only
  ENGINE_ATTRIBUTES = [
    :current_user_proc,
    :javascript_proc
  ]

  # Can be set in initializer or passed as an option to acts_as_commontator
  COMMONTATOR_ATTRIBUTES = [
    :user_name_proc,
    :user_link_proc,
    :user_avatar_proc,
    :user_email_proc,
    :user_mentions_proc
  ]

  # Can be set in initializer or passed as an option to acts_as_commontable
  COMMONTABLE_ATTRIBUTES = [
    :comment_filter,
    :thread_read_proc,
    :thread_moderator_proc,
    :comment_editing,
    :comment_deletion,
    :moderator_permissions,
    :comment_voting,
    :vote_count_proc,
    :comment_order,
    :thread_subscription,
    :email_from_proc,
    :commontable_name_proc,
    :comment_url_proc,
    :new_comment_style,
    :comment_reply_style,
    :comments_per_page,
    :mentions_enabled
  ]

  DEPRECATED_ATTRIBUTES = [
    [:moderators_can_edit_comments, :moderator_permissions],
    [:hide_deleted_comments, :comment_filter],
    [:hide_closed_threads, :thread_read_proc],
    [:wp_link_renderer_proc],
    [:voting_text_proc, :vote_count_proc],
    [:user_name_clickable, :user_link_proc],
    [:user_admin_proc, :thread_moderator_proc],
    [:auto_subscribe_on_comment, :thread_subscription],
    [:can_edit_own_comments, :comment_editing],
    [:can_edit_old_comments, :comment_editing],
    [:can_delete_own_comments, :comment_deletion],
    [:can_delete_old_comments, :comment_deletion],
    [:can_subscribe_to_thread, :thread_subscription],
    [:can_vote_on_comments, :comment_voting],
    [:combine_upvotes_and_downvotes, :vote_count_proc],
    [:comments_order, :comment_order],
    [:closed_threads_are_readable, :thread_read_proc],
    [:deleted_comments_are_visible, :comment_filter],
    [:can_read_thread_proc, :thread_read_proc],
    [:can_edit_thread_proc, :thread_moderator_proc],
    [:admin_can_edit_comments, :moderator_permissions],
    [:subscription_email_enable_proc, :user_email_proc],
    [:comment_name, 'config/locales'],
    [:comment_create_verb_present, 'config/locales'],
    [:comment_create_verb_past, 'config/locales'],
    [:comment_edit_verb_present, 'config/locales'],
    [:comment_edit_verb_past, 'config/locales'],
    [:timestamp_format, 'config/locales'],
    [:subscription_email_to_proc, 'config/locales'],
    [:subscription_email_from_proc, :email_from_proc],
    [:subscription_email_subject_proc, 'config/locales'],
    [:comments_ordered_by_votes, :comment_order],
    [:current_user_method, :current_user_proc],
    [:user_missing_name, 'config/locales'],
    [:user_email_method, :user_email_proc],
    [:user_name_method, :user_name_proc],
    [:commontable_id_method],
    [:commontable_url_proc, :comment_url_proc]
  ]

  def self.included(base)
    (ENGINE_ATTRIBUTES + COMMONTATOR_ATTRIBUTES + COMMONTABLE_ATTRIBUTES).each do |attribute|
      base.mattr_accessor attribute
    end

    base.mattr_accessor :show_deprecation_warning
    DEPRECATED_ATTRIBUTES.each do |deprecated, replacement|
      base.define_singleton_method(deprecated) do
        base.show_deprecation_warning = true
        replacement_string = (replacement.nil? ? 'No replacement is available. You can safely remove it from your configuration file.' : "Use `#{replacement.to_s}` instead.")
        warn "\n[COMMONTATOR] Deprecation: `config.#{deprecated.to_s}` is deprecated and has been disabled. #{replacement_string}\n"
      end

      base.define_singleton_method("#{deprecated.to_s}=") { |obj| base.send(deprecated) }
    end

    base.extend ClassMethods
  end

  module ClassMethods
    def configure
      self.show_deprecation_warning = false

      yield self

      warn("\n[COMMONTATOR] We recommend that you backup the config/initializers/commontator.rb file, rename or remove it, run rake commontator:install:initializers to copy the new default one, then configure it to your liking.\n") if show_deprecation_warning
    end

    def commontator_config(user)
      (user && user.is_commontator) ? user.commontator_config : self
    end

    def commontable_config(obj)
      (obj && obj.is_commontable) ? obj.commontable_config : self
    end

    def commontator_name(user)
      commontator_config(user).user_name_proc.call(user)
    end

    def commontator_link(user, routing_proxy)
      commontator_config(user).user_link_proc.call(user, routing_proxy)
    end

    def commontator_email(user, mailer = nil)
      commontator_config(user).user_email_proc.call(user, mailer)
    end

    def commontator_avatar(user, view)
      commontator_config(user).user_avatar_proc.call(user, view)
    end

    def commontator_mentions(user, thread, search_phrase)
      commontator_config(user).user_mentions_proc.call(user, thread, search_phrase)
    end

    def commontable_name(commontable)
      commontable_config(commontable).commontable_name_proc.call(commontable)
    end

    def comment_url(comment, routing_proxy)
      commontable_config(comment.thread.commontable).comment_url_proc.call(comment, routing_proxy)
    end
  end
end
