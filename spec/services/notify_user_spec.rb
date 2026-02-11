# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyUser do
  let(:recipient) { create(:user) }
  let(:contest)   { create(:contest) }

  it "maps ContestNotification" do
    notification = NoticedNotification.create!(recipient: recipient,
                                               type: "ContestNotification",
                                               params: { contest: contest })
    res = described_class.new({ notification_id: notification.id }, notification).call
    expect(res.success).to eq("true")
    expect(res.type).to eq("new_contest")
    expect(res.first_param).to eq(contest)
  end

  it "maps ContestWinnerNotification" do
    notification = NoticedNotification.create!(recipient: recipient,
                                               type: "ContestWinnerNotification",
                                               params: {})
    res = described_class.new({ notification_id: notification.id }, notification).call
    expect(res.success).to eq("true")
    expect(res.type).to eq("contest_winner")
  end
end
