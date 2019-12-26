# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentMailer, type: :mailer do
  before do
    @group = FactoryBot.create(:group, mentor: FactoryBot.create(:user), name: "Test group")
    @assignment = FactoryBot.create(:assignment, group: @group)
    @user = FactoryBot.create(:user)
  end

  describe "#new_assignment_email" do
    let(:mail) { AssignmentMailer.new_assignment_email(@user, @assignment) }

    it "sends new assignment mail" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("New Assignment in #{@group.name}")
    end
  end

  describe "#update_assignment_email" do
    let(:mail) { AssignmentMailer.update_assignment_email(@user, @assignment) }

    it "sends update assignment link" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Assignment Updated in #{@group.name}")
    end
  end

  describe "#deadline_assignment_email" do
    let(:mail) { AssignmentMailer.deadline_assignment_email(@assignment) }

    it "sends update assignment link" do
      expect(mail.to).to eq([User.find_by(id:Group.find_by(id:@assignment.group_id).mentor_id).email])
      expect(mail.subject).to eq("Assignment has reached the deadline in #{@group.name}")
    end
  end
end
