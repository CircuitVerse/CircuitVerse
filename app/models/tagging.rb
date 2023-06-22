# frozen_string_literal: true

#
# == Schema Information
#
# Table name: taggings
#
#  id         :bigint           not null, primary key
#  project_id :bigint
#  tag_id     :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_taggings_on_project_id  (project_id)
#  index_taggings_on_tag_id      (tag_id)
#

class Tagging < ApplicationRecord
  belongs_to :project
  belongs_to :tag
  validates :project_id, uniqueness: { scope: [:tag_id] }
end
