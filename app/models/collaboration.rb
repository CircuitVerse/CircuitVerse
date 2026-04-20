# frozen_string_literal: true

class Collaboration < ApplicationRecord
  belongs_to :user
  belongs_to :project
  # Prevent same user from being added twice to same project
  validates :user_id, uniqueness: { scope: :project_id, message: "is already a collaborator on this project" }
end
