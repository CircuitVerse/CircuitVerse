# frozen_string_literal: true

module AnnouncementsHelper
  def current_announcement
    Announcement.current
  end

  def show_announcement(announcement)
    announcement.count.positive? ? "navbar navbar-announcement navbar-expand-lg bg-white" : "navbar navbar-expand-lg bg-white"
  end
end
