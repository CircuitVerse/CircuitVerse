# frozen_string_literal: true

FactoryBot.define do
  factory :noticed_notification do
    type { %w[StarNotification ForkNotification NewAssignmentNotification NoType] }
  end
end
