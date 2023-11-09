# frozen_string_literal: true

class AnnouncementPolicy < ApplicationPolicy
  attr_reader :user, :announcement

  def initialize(user, announcement)
    @user = user
    @announcement = announcement
  end
end
