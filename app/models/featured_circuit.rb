# frozen_string_literal: true

#
# == Schema Information
#
# Table name: featured_circuits
#
#  id         :bigint           not null, primary key
#  project_id :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_featured_circuits_on_project_id  (project_id)
#

class FeaturedCircuit < ApplicationRecord
  belongs_to :project

  after_create :featured_circuit_email
  validate :project_public

  private

    def project_public
      errors.add(:project, "Featured projects have to be public") if project.project_access_type != "Public"
    end

    def featured_circuit_email
      UserMailer.featured_circuit_email(project.author, project).deliver_later
    end
end
