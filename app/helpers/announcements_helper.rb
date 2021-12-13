# frozen_string_literal: true

module AnnouncementsHelper
  def current_announcement
    Announcement.current
  end
end
