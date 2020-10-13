# frozen_string_literal: true

module AnnouncementsHelper
  def announcement_exists?(announcement)
    announcement.exists?
  end
  
  def current_announcement
    @current_announcement ||= Announcement.current
  end
end
