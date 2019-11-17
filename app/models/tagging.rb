# frozen_string_literal: true

class Tagging < ApplicationRecord
  belongs_to :project
  belongs_to :tag
  validates_uniqueness_of :project_id, scope: [:tag_id]
end
