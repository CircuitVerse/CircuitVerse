# frozen_string_literal: true

class LtiResourceLink < ApplicationRecord
  belongs_to :lti_deployment

  validates :resource_link_id, presence: true, uniqueness: { scope: :lti_deployment_id }
end
