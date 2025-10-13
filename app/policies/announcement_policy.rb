# frozen_string_literal: true

class AnnouncementPolicy < ApplicationPolicy
  # @return [User]
  attr_reader :user
  # @return [Announcement]
  attr_reader :announcement

  # @param [User] user
  # @param [Announcement] announcement
  def initialize(user, announcement)
    @user = user
    @announcement = announcement
  end
end
