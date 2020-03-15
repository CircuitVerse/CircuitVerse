module Commontator
  class Comment < ActiveRecord::Base
    belongs_to :creator, polymorphic: true
    belongs_to :editor, polymorphic: true, optional: true
    belongs_to :thread

    validates_presence_of :creator, on: :create
    validates_presence_of :editor, on: :update
    validates_presence_of :thread
    validates_presence_of :body

    validates_uniqueness_of :body,
      scope: [:creator_type, :creator_id, :thread_id, :deleted_at],
      message: I18n.t('commontator.comment.errors.double_posted')

    protected

    cattr_accessor :acts_as_votable_initialized

    public

    def is_modified?
      !editor.nil?
    end

    def is_latest?
      thread.comments.last == self
    end

    def is_votable?
      return true if acts_as_votable_initialized
      return false unless self.class.respond_to?(:acts_as_votable)
      self.class.acts_as_votable
      self.class.acts_as_votable_initialized = true
    end

    def get_vote_by(user)
      return nil unless is_votable? && !user.nil? && user.is_commontator
      votes_for.where(voter_type: user.class.name, voter_id: user.id).first
    end

    def update_cached_votes(vote_scope = nil)
      self.update_column(:cached_votes_up, count_votes_up(true))
      self.update_column(:cached_votes_down, count_votes_down(true))
    end

    def is_deleted?
      !deleted_at.blank?
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
      user == creator && !user.nil? && user.is_commontator &&\
      !thread.is_closed? && thread.can_be_read_by?(user)
    end

    def can_be_edited_by?(user)
      return true if thread.can_be_edited_by?(user) &&\
                     thread.config.moderator_permissions.to_sym == :e
      comment_edit = thread.config.comment_editing.to_sym
      !thread.is_closed? && !is_deleted? && user == creator &&\
      comment_edit != :n && (is_latest? || comment_edit == :a) &&\
      thread.can_be_read_by?(user)
    end

    def can_be_deleted_by?(user)
      mod_perm = thread.config.moderator_permissions.to_sym
      return true if thread.can_be_edited_by?(user) &&\
                     (mod_perm == :e ||\
                       mod_perm == :d)
      comment_del = thread.config.comment_deletion.to_sym
      !thread.is_closed? && (!is_deleted? || editor == user) &&\
      user == creator && comment_del != :n &&\
      (is_latest? || comment_del == :a) &&\
      thread.can_be_read_by?(user)
    end

    def can_be_voted_on?
      !thread.is_closed? && !is_deleted? &&\
      thread.config.comment_voting.to_sym != :n && is_votable?
    end

    def can_be_voted_on_by?(user)
      !user.nil? && user.is_commontator && user != creator &&\
      thread.can_be_read_by?(user) && can_be_voted_on?
    end
  end
end
