# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  before do
    @user = create(:user)
    @project = create(:project, author: @user)
    @mail = create(:custom_mail, subject: "Test subject",
                                 content: "Test content", sender: create(:user))
  end

  describe "#custom_email" do
    let(:mail) { described_class.custom_email(@user, @mail) }

    it "sends custom mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq(@mail.subject)
    end
  end

  describe "#welcome_email" do
    let(:mail) { described_class.welcome_email(@user) }

    it "sends welcome mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Signing up Confirmation")
    end
  end

  describe "#new_project_email" do
    let(:mail) { described_class.new_project_email(@user, @project) }

    it "sends new project mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("New Project Created")
    end
  end

  describe "#forked_project_email" do
    let(:mail) { described_class.forked_project_email(@user, @old_project, @forked_project) }

    before do
      @old_project = create(:project, author: create(:user))
      @forked_project = create(:project, author: @user, forked_project: @old_project)
    end

    it "sends forked project mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("New Project Created")
    end
  end

  describe "#featured_circuit_email" do
    let(:mail) { described_class.featured_circuit_email(@user, @project) }

    it "sends featured circuit mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Your project is now featured!")
    end
  end
end
