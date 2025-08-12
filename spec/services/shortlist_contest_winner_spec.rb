# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShortlistContestWinner do
  include ActiveJob::TestHelper

  let(:contest) { create(:contest, status: :live) }

  context "completed contest" do
    it "returns message without touching db" do
      contest.update!(status: :completed)

      expect(described_class.new(contest.id).call[:message])
        .to eq("Contest already completed")
    end
  end

  context "no submissions" do
    it "returns graceful error" do
      res = described_class.new(contest.id).call

      expect(res[:success]).to be false
      expect(res[:message]).to eq("No submissions found")
    end
  end

  context "happy path" do
    let(:top) { create(:submission, :with_private_project, contest: contest) }
    let(:low) { create(:submission, :with_private_project, contest: contest) }

    before do
      allow(FeaturedCircuit).to receive(:create!).and_return(true)
      3.times { create(:submission_vote, submission: top, contest: contest) }
      create(:submission_vote, submission: low, contest: contest)
    end

    it "marks winner, completes contest, and delivers a winner notification" do
      clear_enqueued_jobs

      perform_enqueued_jobs do
        res = described_class.new(contest.id).call
        expect(res[:success]).to be true
      end

      expect(contest.reload.status).to eq("completed")
      expect(top.reload.winner).to be true
      expect(
        ContestWinner.exists?(contest: contest, submission: top)
      ).to be true

      expect(
        NoticedNotification.exists?(recipient: top.project.author,
                                    type: "ContestWinnerNotification")
      ).to be true
    end
  end

  context "RecordNotUnique replay" do
    it "swallows the exception" do
      allow(FeaturedCircuit).to receive(:create!).and_return(true)
      create(:submission, :with_private_project, contest: contest)

      described_class.new(contest.id).call
      res = described_class.new(contest.id).call

      expect(res[:message]).to eq("Contest already completed")
    end
  end

  context "RecordInvalid rescue" do
    it "returns false when create! blows up" do
      create(:submission, :with_private_project, contest: contest)

      allow(ContestWinner).to receive(:create!)
        .and_raise(ActiveRecord::RecordInvalid.new(ContestWinner.new))

      res = described_class.new(contest.id).call

      expect(res[:success]).to be false
    end
  end
end
