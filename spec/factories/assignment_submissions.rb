# frozen_string_literal: true

FactoryBot.define do
  factory :assignment_submission do
    status       { :draft }
    submitted_at { Time.zone.now }
    association  :project
    association  :user

    assignment do
      mentor = create(:user)
      group  = create(:group, primary_mentor: mentor)
      create(:assignment, group: group)
    end
  end
end
