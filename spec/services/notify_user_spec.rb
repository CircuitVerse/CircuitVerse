# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyUser do
  let(:recipient) { create(:user) }
  let(:contest)   { create(:contest) }

  it "maps ContestNotification" do
    n = NoticedNotification.create!(recipient: recipient,
                                    type: "ContestNotification",
                                    params: { contest: contest })
    res = described_class.new(notification_id: n.id).call
    expect(res.success).to eq("true")
    expect(res.type).to eq("new_contest")
    expect(res.first_param).to eq(contest)
  end

  it "maps ContestWinnerNotification" do
    n = NoticedNotification.create!(recipient: recipient,
                                    type: "ContestWinnerNotification",
                                    params: {})
    res = described_class.new(notification_id: n.id).call
    expect(res.success).to eq("true")
    expect(res.type).to eq("contest_winner")
  end

  context "when resource is missing" do
    it "handles ForkNotification with missing project" do
      n = NoticedNotification.create!(recipient: recipient,
                                      type: "ForkNotification",
                                      params: { project: nil })
      res = described_class.new(notification_id: n.id).call
      expect(res.success).to eq("false")
    end

    it "handles StarNotification with missing project" do
      n = NoticedNotification.create!(recipient: recipient,
                                      type: "StarNotification",
                                      params: { project: nil })
      res = described_class.new(notification_id: n.id).call
      expect(res.success).to eq("false")
    end

    it "handles NewAssignmentNotification with missing assignment" do
      n = NoticedNotification.create!(recipient: recipient,
                                      type: "NewAssignmentNotification",
                                      params: { assignment: nil })
      res = described_class.new(notification_id: n.id).call
      expect(res.success).to eq("false")
    end
  end
end
