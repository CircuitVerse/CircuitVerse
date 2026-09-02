# frozen_string_literal: true

# Mirrors the comment permissions in commontator-7.0.1, as configured in
# config/initializers/commontator.rb:
#
#   comment_editing       = :a  -> authors may always edit their own comments
#   comment_deletion      = :a  -> authors may always delete their own comments
#   moderator_permissions = :d  -> moderators may delete and close, not edit
#   comment_voting        = :ld -> likes and dislikes are both enabled
#
# Intentionally does not call super, for the same reason as
# CommentThreadPolicy: comments on public projects are readable anonymously.
class CommentPolicy < ApplicationPolicy
  attr_reader :user, :comment

  delegate :show?, to: :thread_policy

  def initialize(user, comment)
    @user = user
    @comment = comment
  end

  def create?
    thread_policy.create_comment?
  end

  # Commontator#can_be_edited_by?: moderators are excluded here because
  # moderator_permissions is :d rather than :e.
  def update?
    author? &&
      !comment.deleted? &&
      !thread_closed? &&
      (comment.editor_id.nil? || comment.editor_id == user.id) &&
      show?
  end

  # Commontator#can_be_deleted_by?: the moderator branch returns before the
  # closed-thread check, so moderators may still delete in a closed thread.
  # An author may undelete only a comment they deleted themselves.
  def destroy?
    return true if thread_policy.moderator?

    author? &&
      !thread_closed? &&
      (!comment.deleted? || comment.editor_id == user.id) &&
      show?
  end

  def restore?
    destroy?
  end

  # Commontator#can_be_voted_on_by?: a user may not vote on their own comment,
  # and voting closes along with the thread.
  def vote?
    user.present? &&
      !author? &&
      !comment.deleted? &&
      !thread_closed? &&
      show?
  end

  private

    def author?
      user.present? && comment.user_id == user.id
    end

    def thread_closed?
      comment.comment_thread&.closed? || false
    end

    def thread_policy
      @thread_policy ||= CommentThreadPolicy.new(user, comment.comment_thread)
    end
end
