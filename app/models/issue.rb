# frozen_string_literal: true

class Issue < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :project, optional: true

  validates :title, presence: true
  validates :state, inclusion: { in: %w[open closed] }
  validates :github_id, uniqueness: true, allow_nil: true

  scope :open, -> { where(state: 'open') }
  scope :by_period, ->(start_date, end_date = Time.current) { 
    where(created_at: start_date..end_date) 
  }

  def self.contribution_points
    count * 1
  end

  def contribution_points
    1
  end
end
