# frozen_string_literal: true

arr1 = %w[ForumCommentNotification ForumThreadNotification]
arr2 = %w[StarNotification ForkNotification NewAssignmentNotification NoType]
FactoryBot.define do
  factory :noticed_notification do
    type { arr2.concat(arr1) }
  end
end
