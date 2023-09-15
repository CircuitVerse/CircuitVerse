# frozen_string_literal: true

require "rails_helper"

RSpec.describe Announcement, type: :model do
  describe ".current" do
    it "returns the most recently created announcement" do
      # Create multiple announcements with different created_at timestamps
      described_class.create(created_at: 1.day.ago)
      described_class.create(created_at: 2.days.ago)
      announcement3 = described_class.create(created_at: Time.current)

      # Call the current method and expect the most recent announcement to be returned
      expect(described_class.current).to eq(announcement3)
    end

    it "returns nil if no announcements exist" do
      # Ensure there are no announcements in the database
      described_class.destroy_all

      # Call the current method and expect nil to be returned
      expect(described_class.current).to be_nil
    end
  end
end
