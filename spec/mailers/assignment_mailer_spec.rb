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
  end

  describe "#update_assignment_email" do
    let(:mail) { described_class.update_assignment_email(@user, @assignment) }

    it "sends update assignment link" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Assignment Updated in #{@group.name}")
    end
  end
end
