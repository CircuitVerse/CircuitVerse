# frozen_string_literal: true

# Notification Events: ForumCommentNotification, ForumThreadNotification, StarNotification, ForkNotification,
# NewAssignmentNotification, NoType

FactoryBot.define do
  factory :noticed_notification do
    type { "StarNotification" }
  end
end
