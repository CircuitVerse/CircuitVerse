# frozen_string_literal: true

#
# == Schema Information
#
# Table name: collaborations
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  project_id :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_collaborations_on_project_id (project_id)
#  index_collaborations_on_user_id    (user_id)
#

class Collaboration < ApplicationRecord
  belongs_to :user
  belongs_to :project
end
