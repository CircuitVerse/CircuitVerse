# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentMailer, type: :mailer do
  before do
    @group = create(:group, primary_mentor: create(:user), name: "Test group")
    @assignment = create(:assignment, group: @group)
    @user = create(:user)
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
