# frozen_string_literal: true

require "rails_helper"

describe CustomMailsHelper do
  include described_class

  describe "#send_mail_in_batches" do
    before do
      stub_const("SUBSCRIBED_USERS_COUNT", 2)
      stub_const("UNSUBSCRIBED_USERS_COUNT", 3)
      (1..SUBSCRIBED_USERS_COUNT).each { create(:user, subscribed: true) }
      (1..UNSUBSCRIBED_USERS_COUNT).each { create(:user, subscribed: false) }

      @mail = create(:custom_mail, subject: "Test subject",
                                   content: "Test content",
                                   sender: create(:user, subscribed: false))
    end

    it "sends mails to all subscribed users" do
      expect do
        send_mail_in_batches(@mail)
      end.to have_enqueued_job.on_queue("mailers").exactly(SUBSCRIBED_USERS_COUNT).times
    end
  end
end
