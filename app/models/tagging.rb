# frozen_string_literal: true

class Tagging < ApplicationRecord
  belongs_to :project
  belongs_to :tag
  validates :project_id, uniqueness: { scope: [:tag_id] }
end
