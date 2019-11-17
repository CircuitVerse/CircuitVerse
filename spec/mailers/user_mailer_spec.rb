# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  before do
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: @user)
    @mail = FactoryBot.create(:custom_mail, subject: "Test subject",
      content: "Test content", sender: FactoryBot.create(:user))
  end

  describe "#custom_email" do
    let(:mail) { UserMailer.custom_email(@user, @mail) }

    it "sends custom mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq(@mail.subject)
    end
  end

  describe "#welcome_email" do
    let(:mail) { UserMailer.welcome_email(@user) }

    it "sends welcome mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Signing up Confirmation")
    end
  end

  describe "#new_project_email" do
    let(:mail) { UserMailer.new_project_email(@user, @project) }

    it "sends new project mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("New Project Created")
    end
  end

  describe "#forked_project_email" do
    let(:mail) { UserMailer.forked_project_email(@user, @old_project, @forked_project) }

    before do
      @old_project = FactoryBot.create(:project, author: FactoryBot.create(:user))
      @forked_project = FactoryBot.create(:project, author: @user, forked_project: @old_project)
    end

    it "sends forked project mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("New Project Created")
    end
  end

  describe "#featured_circuit_email" do
    let(:mail) { UserMailer.featured_circuit_email(@user, @project) }

    it "sends featured circuit mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Your project is now featured!")
    end
  end
end
