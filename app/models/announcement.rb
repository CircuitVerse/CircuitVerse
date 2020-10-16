# frozen_string_literal: true

class Announcement < ApplicationRecord
  def self.current
    @current ||= load_current
    order("created_at desc").first
  end

  def self.load_current
    # fetch from database
  end

  def exists?
    persisted?
  end
end
