# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestWinnerNotification, type: :notification do
  it "returns a non-empty message and icon" do
    Flipper.enable(:contests)

    user    = create(:user)
    contest = create(:contest)
    project = create(:project, author: user)

    described_class.with(contest: contest, project: project).deliver(user)
    db_row     = NoticedNotification.last
    notice_obj = db_row.to_notification

    expect(notice_obj.message).to match(/Congratulations/)
    expect(notice_obj.icon).to be_present
  end
end
