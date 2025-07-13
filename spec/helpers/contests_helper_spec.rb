# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestsHelper, type: :helper do
  describe "#leaderboard_row_class" do
    it "returns the podium CSS classes for first three indices" do
      expect(helper.leaderboard_row_class(0)).to eq "table-gold"
      expect(helper.leaderboard_row_class(1)).to eq "table-silver"
      expect(helper.leaderboard_row_class(2)).to eq "table-bronze"
    end

    it "returns an empty string for other indices" do
      expect(helper.leaderboard_row_class(4)).to eq ""
    end
  end

  describe "#medal_for" do
    it "returns emoji medals for the top three ranks" do
      expect(helper.medal_for(0)).to eq "🏆"
      expect(helper.medal_for(1)).to eq "🥈"
      expect(helper.medal_for(2)).to eq "🥉"
    end

    it "returns rank number (idx + 1) for lower places" do
      expect(helper.medal_for(4)).to eq 5
    end
  end
end
