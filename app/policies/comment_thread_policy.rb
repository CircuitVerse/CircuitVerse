# frozen_string_literal: true

# Mirrors the thread permissions Commontator is currently configured with:
#
#   thread_read_proc      -> public commentable, or ProjectPolicy view access
#   thread_moderator_proc -> user.admin?
#
# Intentionally does not call super: threads on public projects must stay
# readable by anonymous users, matching the current API behaviour where
# unauthenticated requests can list a public project's comments.
class CommentThreadPolicy < ApplicationPolicy
  attr_reader :user, :comment_thread

  def initialize(user, comment_thread)
    @user = user
    @comment_thread = comment_thread
  end

  def show?
    readable?
  end

  def create_comment?
    user.present? && !comment_thread.closed? && readable?
  end

  def subscribe?
    user.present? && readable?
  end

  def unsubscribe?
    subscribe?
  end

  def close?
    moderator?
  end

  def reopen?
    moderator?
  end

  # moderator_permissions is :d, so moderators may delete comments and close
  # threads, but may not edit other people's comments.
  def moderator?
    user.present? && user.admin?
  end

  private

    def readable?
      commentable = comment_thread.commentable
      return false if commentable.nil?
      return true if commentable.public?

      ProjectPolicy.new(user, commentable).check_view_access?
    end
end
