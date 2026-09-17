# frozen_string_literal: true

FactoryBot.define do
  factory :lti_resource_link do
    lti_deployment
    sequence(:resource_link_id) { |n| "resource-link-#{n}" }
    sequence(:context_id) { |n| "course-#{n}" }
    title { "Week 1 Lab" }
    lineitems_url { "#{lti_deployment.issuer}/api/lti/courses/1/line_items" }
    lineitem_url { "#{lti_deployment.issuer}/api/lti/courses/1/line_items/1" }
    context_memberships_url { "#{lti_deployment.issuer}/api/lti/courses/1/names_and_roles" }
  end
end
