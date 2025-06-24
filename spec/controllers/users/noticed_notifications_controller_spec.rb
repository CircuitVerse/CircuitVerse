# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::NoticedNotificationsController, type: :controller do
  describe "#redirect_path_for" do
    it "returns contest_page_path for ContestNotification" do
      Flipper.enable(:contests)

      user    = create(:user)
      contest = create(:contest)

      ContestNotification.with(contest: contest).deliver(user)
      notice_row = NoticedNotification.last

      answer = NotifyUser.new(notification_id: notice_row.id).call

      controller = described_class.new

      # 👉 **This line fixes the failure**
      allow(controller).to receive(:default_url_options).and_return(host: "www.example.com")

      path = controller.send(:redirect_path_for, answer)
      expect(path).to eq("/contests/#{contest.id}")
    end
  end
end
