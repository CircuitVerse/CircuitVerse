# frozen_string_literal: true

module AnnouncementBox
  class AnnouncementComponent < ViewComponent::Base
    def initialize(current_announcement)
      super
      @current_announcement = current_announcement
    end
  end
end
