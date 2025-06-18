# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShortlistContestWinner, type: :service do
  describe "#call" do
    let!(:contest)    { create(:contest, status: :live) }
    let!(:submission) { create(:submission, contest: contest) }

    let(:mailer) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(ContestWinnerNotification).to receive(:with).and_return(mailer)
      allow(mailer).to receive(:deliver_later)

      allow(FeaturedCircuit).to receive(:create!)
    end

    it "creates a winner, marks submission and contest completed, enqueues notification, and returns success" do
      expect(ContestWinnerNotification).to receive(:with)
        .with(user: submission.user, contest: contest, submission: submission).once
      expect(mailer).to receive(:deliver_later).once

      service = described_class.new(contest.id)

      result = nil
      expect do
        result = service.call
      end.to change(ContestWinner, :count).by(1)
                                          .and change { submission.reload.winner }.from(false).to(true)
                                                                                  .and change {
                                                                                         contest.reload.completed?
                                                                                       }.from(false).to(true)

      expect(result).to include(success: true)
    end
  end
end
