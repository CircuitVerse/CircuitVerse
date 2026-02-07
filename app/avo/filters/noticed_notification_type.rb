# frozen_string_literal: true

class Avo::Filters::NoticedNotificationType < Avo::Filters::SelectFilter
  self.name = "Type"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(type: value)
  end

  def options
    {
      "ContestNotification" => "Contest Notification",
      "ContestWinnerNotification" => "Contest Winner Notification",
      "ForkNotification" => "Fork Notification",
      "ForumCommentNotification" => "Forum Comment Notification",
      "ForumThreadNotification" => "Forum Thread Notification",
      "NewAssignmentNotification" => "New Assignment Notification",
      "StarNotification" => "Star Notification"
    }
  end
end
