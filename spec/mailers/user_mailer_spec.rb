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
    let(:mail) { described_class.custom_email(@user, @mail) }

    it "sends custom mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq(@mail.subject)
    end

    it "supports scalar IDs as arguments" do
      mail_from_ids = described_class.custom_email(@user.id, @mail.id)
      expect(mail_from_ids.to).to eq([@user.email])
      expect(mail_from_ids.subject).to eq(@mail.subject)
    end

    it "handles missing/deleted records gracefully" do
      expect(described_class.custom_email(999_999, @mail.id).message).to be_a(ActionMailer::Base::NullMail)
      expect(described_class.custom_email(@user.id, 999_999).message).to be_a(ActionMailer::Base::NullMail)
    end

    it "does not deliver if user opted out" do
      allow(@user).to receive(:opted_out?).and_return(true)
      expect(described_class.custom_email(@user, @mail).message).to be_a(ActionMailer::Base::NullMail)
    end
  end

  describe "#welcome_email" do
    let(:mail) { described_class.welcome_email(@user) }

    it "sends welcome mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Signing up Confirmation")
    end

    it "supports scalar ID as argument" do
      mail_from_id = described_class.welcome_email(@user.id)
      expect(mail_from_id.to).to eq([@user.email])
      expect(mail_from_id.subject).to eq("Signing up Confirmation")
    end

    it "handles missing/deleted user gracefully" do
      expect(described_class.welcome_email(999_999).message).to be_a(ActionMailer::Base::NullMail)
    end
  end

  describe "#new_project_email" do
    let(:mail) { described_class.new_project_email(@user, @project) }

    it "sends new project mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("New Project Created")
    end

    it "supports scalar IDs as arguments" do
      mail_from_ids = described_class.new_project_email(@user.id, @project.id)
      expect(mail_from_ids.to).to eq([@user.email])
      expect(mail_from_ids.subject).to eq("New Project Created")
    end

    it "handles missing/deleted records gracefully" do
      expect(described_class.new_project_email(999_999, @project.id).message).to be_a(ActionMailer::Base::NullMail)
      expect(described_class.new_project_email(@user.id, 999_999).message).to be_a(ActionMailer::Base::NullMail)
    end

    it "does not deliver if user opted out" do
      allow(@user).to receive(:opted_out?).and_return(true)
      expect(described_class.new_project_email(@user, @project).message).to be_a(ActionMailer::Base::NullMail)
    end
  end

  describe "#forked_project_email" do
    let(:mail) { described_class.forked_project_email(@user, @old_project, @forked_project) }

    before do
      @old_project = FactoryBot.create(:project, author: FactoryBot.create(:user))
      @forked_project = FactoryBot.create(:project, author: @user, forked_project: @old_project)
    end

    it "sends forked project mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("New Project Created")
    end

    it "supports scalar IDs as arguments" do
      mail_from_ids = described_class.forked_project_email(@user.id, @old_project.id, @forked_project.id)
      expect(mail_from_ids.to).to eq([@user.email])
      expect(mail_from_ids.subject).to eq("New Project Created")
    end

    it "handles missing/deleted records gracefully" do
      expect(described_class.forked_project_email(999_999, @old_project.id, @forked_project.id).message).to be_a(ActionMailer::Base::NullMail)
      expect(described_class.forked_project_email(@user.id, 999_999, @forked_project.id).message).to be_a(ActionMailer::Base::NullMail)
      expect(described_class.forked_project_email(@user.id, @old_project.id, 999_999).message).to be_a(ActionMailer::Base::NullMail)
    end

    it "does not deliver if user opted out" do
      allow(@user).to receive(:opted_out?).and_return(true)
      expect(described_class.forked_project_email(@user, @old_project, @forked_project).message).to be_a(ActionMailer::Base::NullMail)
    end
  end

  describe "#featured_circuit_email" do
    let(:mail) { described_class.featured_circuit_email(@user, @project) }

    it "sends featured circuit mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Your project is now featured!")
    end

    it "supports scalar IDs as arguments" do
      mail_from_ids = described_class.featured_circuit_email(@user.id, @project.id)
      expect(mail_from_ids.to).to eq([@user.email])
      expect(mail_from_ids.subject).to eq("Your project is now featured!")
    end

    it "handles missing/deleted records gracefully" do
      expect(described_class.featured_circuit_email(999_999, @project.id).message).to be_a(ActionMailer::Base::NullMail)
      expect(described_class.featured_circuit_email(@user.id, 999_999).message).to be_a(ActionMailer::Base::NullMail)
    end

    it "does not deliver if user opted out" do
      allow(@user).to receive(:opted_out?).and_return(true)
      expect(described_class.featured_circuit_email(@user, @project).message).to be_a(ActionMailer::Base::NullMail)
    end
  end
end
