# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentMailer, type: :mailer do
  before do
    @group = FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user), name: "Test group")
    @assignment = FactoryBot.create(:assignment, group: @group)
    @user = FactoryBot.create(:user)
  end

  describe "#new_assignment_email" do
    let(:mail) { described_class.new_assignment_email(@user, @assignment) }

    it "sends new assignment mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("New Assignment in #{@group.name}")
    end

    it "supports scalar IDs as arguments" do
      mail_from_ids = described_class.new_assignment_email(@user.id, @assignment.id)
      expect(mail_from_ids.to).to eq([@user.email])
      expect(mail_from_ids.subject).to eq("New Assignment in #{@group.name}")
    end

    it "handles missing/deleted records gracefully" do
      expect(described_class.new_assignment_email(999_999, @assignment.id).message).to be_a(ActionMailer::Base::NullMail)
      expect(described_class.new_assignment_email(@user.id, 999_999).message).to be_a(ActionMailer::Base::NullMail)
    end

    it "does not deliver if user opted out" do
      allow(@user).to receive(:opted_out?).and_return(true)
      expect(described_class.new_assignment_email(@user, @assignment).message).to be_a(ActionMailer::Base::NullMail)
    end
  end

  describe "#update_assignment_email" do
    let(:mail) { described_class.update_assignment_email(@user, @assignment) }

    it "sends update assignment link" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Assignment Updated in #{@group.name}")
    end

    it "supports scalar IDs as arguments" do
      mail_from_ids = described_class.update_assignment_email(@user.id, @assignment.id)
      expect(mail_from_ids.to).to eq([@user.email])
      expect(mail_from_ids.subject).to eq("Assignment Updated in #{@group.name}")
    end

    it "handles missing/deleted records gracefully" do
      expect(described_class.update_assignment_email(999_999, @assignment.id).message).to be_a(ActionMailer::Base::NullMail)
      expect(described_class.update_assignment_email(@user.id, 999_999).message).to be_a(ActionMailer::Base::NullMail)
    end

    it "does not deliver if user opted out" do
      allow(@user).to receive(:opted_out?).and_return(true)
      expect(described_class.update_assignment_email(@user, @assignment).message).to be_a(ActionMailer::Base::NullMail)
    end
  end
end
