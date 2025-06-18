# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyUser, type: :service do
  describe "#call for ContestWinnerNotification" do
    let(:contest)      { build_stubbed(:contest) }
    let(:notification) do
      instance_double(
        NoticedNotification,
        id: 99,
        type: "ContestWinnerNotification",
        params: { contest: contest }
      )
    end

    before do
      allow(NoticedNotification).to receive(:find).with(99).and_return(notification)
    end

    it "returns a success Result with type contest_winner" do
      result = described_class.new(notification_id: 99).call

      expect(result).to be_a(NotifyUser::Result)
      expect(result.success).to eq("true")
      expect(result.type).to    eq("contest_winner")
    end
  end
end
