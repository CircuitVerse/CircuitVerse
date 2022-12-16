class Commontator::Comment < ActiveRecord::Base
  belongs_to :creator, polymorphic: true
  belongs_to :editor, polymorphic: true, optional: true
  belongs_to :thread, inverse_of: :comments
  belongs_to :parent, optional: true, class_name: name, inverse_of: :children

  has_many :children, class_name: name, foreign_key: :parent_id, inverse_of: :parent

  validates :editor, presence: true, on: :update
  validates :body, presence: true, uniqueness: {
    scope: [ :creator_type, :creator_id, :thread_id, :deleted_at ], message: :double_posted
  }
  validate :parent_is_not_self, :parent_belongs_to_the_same_thread, if: :parent

  cattr_accessor :is_votable
  self.is_votable = begin
    require 'acts_as_votable'
    acts_as_votable

    true
  rescue LoadError
    false
  end

  def self.is_votable?
    is_votable
  end

  def is_modified?
    !editor.nil?
  end

  def is_latest?
    thread.latest_comment(false) == self
  end

  def get_vote_by(user)
    return nil unless self.class.is_votable? && !user.nil? && user.is_commontator

    # Preloaded with a condition in thread#nested_comments_for
    votes_for.to_a.find { |vote| vote.voter_id == user.id && vote.voter_type == user.class.name }
  end

  def update_cached_votes(vote_scope = nil)
    self.update_column(:cached_votes_up, count_votes_up(true))
    self.update_column(:cached_votes_down, count_votes_down(true))
  end

  def is_deleted?
    !deleted_at.nil?
  end

  def delete_by(user)
    return false if is_deleted?

    self.deleted_at = Time.now
    self.editor = user
    self.save
  end

  def undelete_by(user)
    return false unless is_deleted?

    self.deleted_at = nil
    self.editor = user
    self.save
  end

  def body
    is_deleted? ? I18n.t(
      'commontator.comment.status.deleted_by', deleter_name: Commontator.commontator_name(editor)
    ) : super
  end

  def created_timestamp
    I18n.t 'commontator.comment.status.created_at',
           created_at: I18n.l(created_at, format: :commontator)
  end

  def updated_timestamp
    I18n.t 'commontator.comment.status.updated_at',
           editor_name: Commontator.commontator_name(editor || creator),
           updated_at: I18n.l(updated_at, format: :commontator)
  end

  ##################
  # Access Control #
  ##################

  def can_be_created_by?(user)
    user == creator && !user.nil? && user.is_commontator &&
    !thread.is_closed? && thread.can_be_read_by?(user)
  end

  def can_be_edited_by?(user)
    return true if thread.can_be_edited_by?(user) &&
                   thread.config.moderator_permissions.to_sym == :e

    comment_edit = thread.config.comment_editing.to_sym
    !thread.is_closed? && !is_deleted? && user == creator && (editor.nil? || user == editor) &&
    comment_edit != :n && (is_latest? || comment_edit == :a) && thread.can_be_read_by?(user)
  end

  def can_be_deleted_by?(user)
    mod_perm = thread.config.moderator_permissions.to_sym
    return true if thread.can_be_edited_by?(user) && (mod_perm == :e || mod_perm == :d)

    comment_del = thread.config.comment_deletion.to_sym
    !thread.is_closed? && user == creator && (!is_deleted? || editor == user) &&
    comment_del != :n && (is_latest? || comment_del == :a) && thread.can_be_read_by?(user)
  end

  def can_be_voted_on?
    !thread.is_closed? && !is_deleted? && thread.is_votable? && self.class.is_votable?
  end

  def can_be_voted_on_by?(user)
    !user.nil? && user.is_commontator && user != creator &&
    thread.can_be_read_by?(user) && can_be_voted_on?
  end

  protected

  # These 2 validation messages are not currently translated because end users should never see them
  def parent_is_not_self
    return if parent != self
    errors.add :parent, 'must be a different comment'
    throw :abort
  end

  def parent_belongs_to_the_same_thread
    return if parent.thread_id == thread_id
    errors.add :parent, 'must belong to the same thread'
    throw :abort
  end
end
