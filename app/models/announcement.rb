# frozen_string_literal: true

class Announcement < ApplicationRecord
  def self.current
    order("created_at desc").first
  end

  def exists?
    persisted?
  end
end
