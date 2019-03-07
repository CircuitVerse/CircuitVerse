require 'rails_helper'

RSpec.describe Assignment, type: :model do
  describe "associations" do
    it { should belong_to(:group) }
    it { should have_many(:projects) }
  end

  describe "callbacks", :focus do
    before do
      @mentor = FactoryBot.create(:user)
      @group = FactoryBot.create(:group, mentor: @mentor)
    end

    it "should call respective callbacks" do
      expect_any_instance_of(Assignment).to receive(:send_new_assignment_mail)
      expect_any_instance_of(Assignment).to receive(:send_update_mail)
      expect_any_instance_of(Assignment).to receive(:set_deadline_job).twice
      assignment = FactoryBot.create(:assignment, group: @group)
      assignment.status = 'open'
      assignment.save
    end
  end
end
