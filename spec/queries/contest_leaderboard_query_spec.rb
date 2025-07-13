# frozen_string_literal: true
require "rails_helper"

RSpec.describe ContestLeaderboardQuery do
  describe ".call" do
    let(:contest) { create(:contest) }

    let!(:oldest)   { create(:submission, contest:, created_at: 3.days.ago) }
    let!(:middle)   { create(:submission, contest:, created_at: 2.days.ago) }
    let!(:newest)   { create(:submission, contest:, created_at: 1.day.ago) }

    before do
      create_list(:submission_vote, 3, submission: oldest, contest:)
      create_list(:submission_vote, 3, submission: middle, contest:)
      create_list(:submission_vote, 1, submission: newest, contest:)
    end

    it "orders by votes desc and then by creation time asc" do
      ranked_ids = described_class.call(contest).map(&:id)
      expect(ranked_ids).to eq [oldest.id, middle.id, newest.id]
    end

    it "exposes votes_count on each returned record" do
      first = described_class.call(contest).first
      expect(first.respond_to?(:votes_count)).to be true
      expect(first.votes_count).to eq 3
    end
  end
end
