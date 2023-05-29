# frozen_string_literal: true

#
# == Schema Information
#
# Table name: announcements
#
#  id         :bigint           not null, primary key
#  body       :text
#  link       :text
#  start_date :datetime
#  end_date   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Announcement < ApplicationRecord
  def self.current
    order("created_at desc").first
  end

  def exists?
    persisted?
  end
end
