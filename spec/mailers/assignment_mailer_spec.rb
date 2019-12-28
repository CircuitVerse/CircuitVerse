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

  describe '#deadline_assignment_email' do
    let(:mail) { AssignmentMailer.deadline_assignment_email(@assignment, @projects_submitted, @projects_not_submitted) }

    it "sends update assignment link" do
      @group = Group.find_by(id: @assignment.group_id)
      @mentor = User.find_by(id: @group.mentor_id)
      expect(mail.to).to eq([@mentor.email])
      @eq_string = "Assignment has reached the deadline in #{@group.name}"
      expect(mail.subject).to eq(@eq_string)
    end
  end
end
