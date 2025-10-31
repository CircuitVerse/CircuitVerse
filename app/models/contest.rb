class Contest < ApplicationRecord
  has_noticed_notifications model_name: "NoticedNotification"

  has_many :submissions, dependent: :destroy
  has_many :submission_votes, dependent: :destroy
  has_one :contest_winner, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :submission_votes, dependent: :destroy
  has_one :contest_winner, dependent: :destroy

  enum :status, { live: 0, completed: 1 }

  # ADDED: General validation for name presence.
  validates :name, presence: true 

  validates :deadline, presence: true
  validate :deadline_must_be_in_future, unless: :completed?
  validates :status, presence: true
  validate :only_one_live_contest, if: -> { live? && will_save_change_to_status? }

  self.per_page = 8

  # MODIFIED: Removed 'on: :create' from set_default_name.
  # ADDED: New callback to fix the name after the record is committed and has a final ID.
  before_validation :set_default_name
  after_commit :normalize_default_name, if: -> { @default_name_assigned }

  private

  def set_default_name
    # REVISED: Only run if the name is not present.
    return if name.present?

    # REVISED: Mark that a default name was assigned, triggering the after_commit hook.
    @default_name_assigned = true

    # REVISED: Calculates the next likely ID to use as a placeholder name.
    # If the record has an ID, use it (shouldn't happen here). Otherwise, 
    # look up the maximum existing ID and add 1.
    next_number = id || Contest.unscoped.maximum(:id).to_i + 1
    
    self.name = "Contest ##{next_number}"
  end

  # NEW: This method runs AFTER the contest record has been saved and has its official ID.
  def normalize_default_name
    # Skip if the record somehow doesn't have an ID (shouldn't happen).
    return unless id.present?

    # If the placeholder name accidentally matched the final ID, clear the flag and exit.
    if name == "Contest ##{id}"
      @default_name_assigned = false
      return
    end

    # FINAL FIX: Use update_column to directly update the database with the correct name, 
    # forcing it to use the guaranteed, final `id`.
    # This skips validations and callbacks, which is safe here.
    update_column(:name, "Contest ##{id}")

    @default_name_assigned = false
  end

  def deadline_must_be_in_future
    return unless deadline.present? && deadline < Time.zone.now

    errors.add(:deadline, :in_the_past, message: "must be in the future")
  end

  def only_one_live_contest
    return unless Contest.live.where.not(id: id).exists?
    
    errors.add(:status, :already_live, message: "Another contest is already live")
  end
end