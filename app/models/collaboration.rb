# frozen_string_literal: true

class Collaboration < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :user_id, uniqueness: { scope: :project_id }
  validate :user_is_not_project_owner

  private

  def user_is_not_project_owner
    if project&.author_id == user_id
      errors.add(:user, "cannot be the owner of the project")
    end
  end
end