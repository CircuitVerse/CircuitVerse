# frozen_string_literal: true

require "rails_helper"

describe CustomMailsController, type: :request do
  before do
    @mail = FactoryBot.create(:custom_mail, subject: "Test subject",
      content: "Test content",
      sender: FactoryBot.create(:user, subscribed: false))
  end

  context "admin is signed in" do
    before do
      sign_in FactoryBot.create(:user, admin: true, subscribed: false)
    end

    describe "#create" do
      let(:create_params) do
        {
          custom_mail: {
            content: "Test content",
            subject: "Test subject"
           }
         }
      end

      it "should create a new custom mail" do
        expect {
          post custom_mails_path, params: create_params
        }.to change { CustomMail.count }.by(1)
      end
    end

    describe "#show" do
      it "should show the mail" do
        get custom_mail_path(@mail)
        expect(response.body).to include(@mail.subject)
        expect(response.body).to include(@mail.content)
      end
    end

    describe "#update" do
      let(:update_params) do
        {
          custom_mail: {
            subject: "Updated subject"
          }
        }
      end

      it "updates mails" do
        expect {
          put custom_mail_path(@mail), params: update_params
          @mail.reload
        }.to change { @mail.subject }.to("Updated subject")
      end
    end

    describe "#send_mail" do
      before do
        FactoryBot.create(:user, subscribed: true)
      end

      it "should send all mails" do
        expect {
          get send_custom_mail_path(@mail)
        }.to have_enqueued_job.on_queue("mailers")
        expect(response.body).to eq("The mails were queued for sending!")
      end
    end

    describe "#send_mail_self" do
      before do
        FactoryBot.create(:user, subscribed: true)
      end

      it "should send mail to send only" do
        expect {
          get send_custom_mail_self_path(@mail)
        }.to have_enqueued_job.on_queue("mailers")
        expect(response.body).to eq("A mail has been sent to your email!")
      end
    end
  end

  context "user is not admin" do
    it "should return not authorized for all routes" do
      sign_in FactoryBot.create(:user)
      get send_custom_mail_path(@mail)
      check_not_authorized(response)
      put custom_mail_path(@mail), params: { custom_mail: {} }
      check_not_authorized(response)
      post custom_mails_path, params: { custom_mail: {} }
      check_not_authorized(response)
    end
  end
end
