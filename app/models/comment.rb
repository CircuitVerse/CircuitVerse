# frozen_string_literal: true

class Comment < ApplicationRecord
  acts_as_votable

  belongs_to :creator, polymorphic: true
  belongs_to :editor, polymorphic: true, optional: true
  belongs_to :thread, class_name: "CommentThread", inverse_of: :comments

  validates :editor, presence: true, on: :update
  # No matching unique index: Postgres treats NULL deleted_at as distinct,
  # so the common (non-deleted) case cannot be enforced at the DB level.
  # App-level check mirrors the old commontator validation.
  validates :body, presence: true, uniqueness: { # rubocop:disable Rails/UniqueValidationWithoutIndex
    scope: %i[creator_type creator_id thread_id deleted_at], message: :double_posted
  }

  def deleted?
    !deleted_at.nil?
  end
  alias is_deleted? deleted?

  def delete_by(user)
    return false if deleted?

    self.deleted_at = Time.zone.now
    self.editor = user
    save
  end

  def undelete_by(user)
    return false unless deleted?

    self.deleted_at = nil
    self.editor = user
    save
  end

  def body
    return super unless deleted?

    I18n.t("comments.deleted_by", deleter_name: (editor || creator)&.name)
  end

  def get_vote_by(user)
    return nil if user.nil?

    votes_for.to_a.find { |vote| vote.voter_id == user.id && vote.voter_type == user.class.name }
  end

  def update_cached_votes(_vote_scope = nil)
    # Skipping validations is intentional: this runs from vote callbacks,
    # where saving would recurse. Mirrors the old commontator override.
    update_column(:cached_votes_up, count_votes_up(true)) # rubocop:disable Rails/SkipsModelValidations
    update_column(:cached_votes_down, count_votes_down(true)) # rubocop:disable Rails/SkipsModelValidations
  end

  def can_be_created_by?(user)
    !user.nil? && user == creator && !thread.closed? && thread.can_be_read_by?(user)
  end

  def can_be_edited_by?(user)
    return true if thread.can_be_edited_by?(user)
    return false if thread.closed? || deleted?

    user == creator && thread.can_be_read_by?(user)
  end

  def can_be_deleted_by?(user)
    return true if thread.can_be_edited_by?(user)
    return false if thread.closed? || user != creator

    (!deleted? || editor == user) && thread.can_be_read_by?(user)
  end

  def can_be_voted_on?
    !thread.closed? && !deleted?
  end

  def can_be_voted_on_by?(user)
    !user.nil? && user != creator && thread.can_be_read_by?(user) && can_be_voted_on?
  end
end
