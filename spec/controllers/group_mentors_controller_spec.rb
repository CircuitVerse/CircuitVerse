# frozen_string_literal: true

require "rails_helper"

describe GroupMentorsController, type: :request do
  before do
    @owner = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, owner: @owner)
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
      sign_in @owner
    end

    context "owner is logged in" do
      it "creates mentors that are not present and pending invitations for others" do
        expect {
          post group_mentors_path, params: create_params
        }.to change { GroupMember.count }.by(1)
         .and change { PendingInvitation.count }.by(1)
      end
    end

    context "user other than owner is logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        post group_mentors_path, params: create_params
        check_not_authorized(response)
      end
    end
  end

  describe "#destroy" do
    before do
      @group_member = FactoryBot.create(:group_member, user: FactoryBot.create(:user),
                                                       group: @group)
    end

    context "owner is signed in" do
      it "destroys group member" do
        sign_in @owner
        expect {
          delete group_member_path(@group_member)
        }.to change { GroupMember.count }.by(-1)
      end
    end

    context "user other than the owner is logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        delete group_member_path(@group_member)
        check_not_authorized(response)
      end
    end
  end
end
