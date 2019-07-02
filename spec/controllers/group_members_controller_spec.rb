# frozen_string_literal: true

require "rails_helper"

describe GroupMembersController, type: :request do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
  end

  describe "#create" do
    let(:create_params) {
      {
        group_member: {
          group_id: @group.id,
          emails: "#{@already_present.email}
           #{FactoryBot.create(:user).email} #{Faker::Internet.email}"
        }
      }
    }

    before do
      @already_present = FactoryBot.create(:user)
      FactoryBot.create(:group_member, user: @already_present, group: @group)
      sign_in @mentor
    end

    context "mentor is logged in" do
      it "creates members that are not present and pending invitations for others" do
        expect {
          post group_members_path, params: create_params
        }.to change { GroupMember.count }.by(1)
         .and change { PendingInvitation.count }.by(1)
      end
    end

    context "user other than mentor is logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        post group_members_path, params: create_params
        check_not_authorized(response)
      end
    end
  end

  describe "#destroy" do
    before do
      @group_member = FactoryBot.create(:group_member, user: FactoryBot.create(:user),
                                                       group: @group)
    end

    context "mentor is signed in" do
      it "destroys group member" do
        sign_in @mentor
        expect {
          delete group_member_path(@group_member)
        }.to change { GroupMember.count }.by(-1)
      end
    end

    context "user other than the mentor is logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        delete group_member_path(@group_member)
        check_not_authorized(response)
      end
    end
  end
end
