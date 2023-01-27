# frozen_string_literal: true

module AnnouncementsHelper
  def current_announcement
    Announcement.current
  end

  def show_announcement
    current_announcement ? "navbar navbar-announcement navbar-expand-lg bg-white" : "navbar navbar-expand-lg bg-white"
  end
end
