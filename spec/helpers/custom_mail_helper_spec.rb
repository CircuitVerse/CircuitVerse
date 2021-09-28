# frozen_string_literal: true

require "rails_helper"

describe CustomMailsHelper do
  SUBSCRIBED_USERS_COUNT = 2
  UNSUBSCRIBED_USERS_COUNT = 3

  include described_class

  describe "#send_mail_in_batches" do
    before do
      (1..SUBSCRIBED_USERS_COUNT).each { FactoryBot.create(:user, subscribed: true) }
      (1..UNSUBSCRIBED_USERS_COUNT).each { FactoryBot.create(:user, subscribed: false) }

      @mail = FactoryBot.create(:custom_mail, subject: "Test subject",
                                              content: "Test content",
                                              sender: FactoryBot.create(:user, subscribed: false))
    end

    it "sends mails to all subscribed users" do
      expect do
        send_mail_in_batches(@mail)
      end.to have_enqueued_job.on_queue("mailers").exactly(SUBSCRIBED_USERS_COUNT).times
    end
  end
end
