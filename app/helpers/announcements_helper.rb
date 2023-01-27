# frozen_string_literal: true

module AnnouncementsHelper
  def current_announcement
    Announcement.current
  end

  def show_announcement(announcement)
    # rubocop:disable Layout/LineLength
    announcement.count.positive? ? "navbar navbar-announcement navbar-expand-lg bg-white" : "navbar navbar-expand-lg bg-white"
    # rubocop:enable Layout/LineLength
  end
end
