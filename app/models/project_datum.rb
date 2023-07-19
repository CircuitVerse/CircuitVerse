# frozen_string_literal: true

#
# == Schema Information
#
# Table name: project_data
#
#  id           :bigint           not null, primary key
#  project_id   :bigint
#  data         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_project_data_on_project_id  (project_id)
#

class ProjectDatum < ApplicationRecord
  belongs_to :project
end
