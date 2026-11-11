# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyUser do
  let(:recipient) { create(:user) }
  let(:contest)   { create(:contest) }

  it "maps ContestNotification" do
    notification = NoticedNotification.create!(recipient: recipient,
                                               type: "ContestNotification",
                                               params: { contest: contest })
    res = described_class.new(notification).call
    expect(res.success).to eq("true")
    expect(res.type).to eq("new_contest")
    expect(res.first_param).to eq(contest)
  end

  it "maps AssignmentCollaboratorNotification to the assignment page" do
    assignment = create(:assignment)
    notification = NoticedNotification.create!(recipient: recipient,
                                               type: "AssignmentCollaboratorNotification",
                                               params: { assignment: assignment })
    res = described_class.new(notification).call
    expect(res.success).to eq("true")
    expect(res.type).to eq("new_assignment")
    expect(res.first_param).to eq(assignment.group)
    expect(res.second).to eq(assignment)
  end

  it "maps ContestWinnerNotification" do
    notification = NoticedNotification.create!(recipient: recipient,
                                               type: "ContestWinnerNotification",
                                               params: {})
    res = described_class.new(notification).call
    expect(res.success).to eq("true")
    expect(res.type).to eq("contest_winner")
  end
end
