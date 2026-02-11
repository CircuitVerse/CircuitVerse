# frozen_string_literal: true

class PullRequest < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :project, optional: true

  validates :title, presence: true
  validates :state, inclusion: { in: %w[open closed merged] }
  validates :github_id, uniqueness: true, allow_nil: true

  scope :merged, -> { where(state: 'merged') }
  scope :open, -> { where(state: 'open') }
  scope :by_period, ->(start_date, end_date = Time.current) { 
    where(created_at: start_date..end_date) 
  }

  def self.contribution_points
    merged.count * 5 + (open.count - merged.count) * 2
  end

  def contribution_points
    state == 'merged' ? 5 : 2
  end
end
