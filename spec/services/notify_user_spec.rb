# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyUser, type: :service do
  it "handles a contest notification without error" do
    Flipper.enable(:contests)

    recipient = create(:user)
    contest   = create(:contest)

    ContestNotification.with(contest: contest).deliver(recipient)
    notice_row = NoticedNotification.last

    result = described_class.new(notification_id: notice_row.id).call

    expect(result).to be_truthy
    expect(result.type).to eq("new_contest")
  end
end
