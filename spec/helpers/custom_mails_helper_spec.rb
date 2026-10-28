# frozen_string_literal: true

require "rails_helper"

describe CustomMailsHelper, type: :helper do
  include described_class
  include ActiveJob::TestHelper

  describe "#send_mail_in_batches" do
    before do
      stub_const("SUBSCRIBED_USERS_COUNT", 2)
      stub_const("UNSUBSCRIBED_USERS_COUNT", 3)
      (1..SUBSCRIBED_USERS_COUNT).each { FactoryBot.create(:user, subscribed: true) }
      (1..UNSUBSCRIBED_USERS_COUNT).each { FactoryBot.create(:user, subscribed: false) }

      @mail = FactoryBot.create(:custom_mail, subject: "Test subject",
                                              content: "Test content",
                                              sender: FactoryBot.create(:user, subscribed: false))
      clear_enqueued_jobs
    end

    it "sends mails to all subscribed users with scalar IDs" do
      expect do
        send_mail_in_batches(@mail)
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob).on_queue("mailers").exactly(SUBSCRIBED_USERS_COUNT).times

      # Check that the enqueued job arguments are scalar IDs rather than GlobalIDs
      custom_mail_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs.select do |job|
        job["arguments"].second == "custom_email"
      end
      enqueued_args = custom_mail_jobs.map { |job| job["arguments"].last["args"] }
      subscribed_user_ids = User.subscribed.pluck(:id)
      enqueued_args.each do |args|
        expect(subscribed_user_ids).to include(args.first)
        expect(args.second).to eq(@mail.id)
      end
    end

    it "executes enqueued mailer jobs cleanly even if user or mail is deleted before processing" do
      send_mail_in_batches(@mail)
      @mail.destroy!

      expect { perform_enqueued_jobs }.not_to raise_error
    end
  end

  describe "#send_mail_to_self" do
    before do
      @user = FactoryBot.create(:user)
      @mail = FactoryBot.create(:custom_mail, subject: "Self mail",
                                              content: "Self content",
                                              sender: @user)
    end

    it "sends mail to user with scalar IDs" do
      expect do
        send_mail_to_self(@user, @mail)
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with("UserMailer", "custom_email", "deliver_now", { args: [@user.id, @mail.id] })
        .on_queue("mailers")
    end
  end
end
