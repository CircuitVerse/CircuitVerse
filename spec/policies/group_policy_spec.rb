# frozen_string_literal: true

require "rails_helper"

describe GroupPolicy do
  subject { GroupPolicy.new(user, group) }

  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
  end

  context "user is mentor" do
    let(:user) { @mentor }
    let(:group) { @group }
    it { should permit(:show_access) }
    it { should permit(:admin_access) }
  end

  context "user is a group_member" do
    let(:user) { @member }
    let(:group) { @group }

    before do
      @member = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: @member)
    end

    it { should permit(:show_access) }
    it { should_not permit(:admin_access) }
  end

  context "user is not a group_member" do
    let(:user) { FactoryBot.create(:user) }
    let(:group) { @group }

    it { should_not permit(:show_access) }
    it { should_not permit(:admin_access) }
  end
end
