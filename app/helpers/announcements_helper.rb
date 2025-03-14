# frozen_string_literal: true

module AnnouncementsHelper
  # @return [Announcement] Current announcement
  def current_announcement
    Announcement.current
  end
end
