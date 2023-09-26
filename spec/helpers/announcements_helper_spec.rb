# frozen_string_literal: true

require "rails_helper"

RSpec.describe Announcement do
  describe "#current_announcement" do
    it "return's the latest Announcement" do
      expect(described_class.current).to eq(described_class.last)
    end
  end
end
