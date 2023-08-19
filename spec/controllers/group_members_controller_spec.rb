# frozen_string_literal: true

require "rails_helper"

describe GroupMembersController, type: :request do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
  end

  describe "#create" do
    let(:create_params) do
      {
        group_member: {
          group_id: @group.id,
          emails: [@already_present.email, FactoryBot.create(:user).email, Faker::Internet.email]
        }
      }
    end

    before do
      @already_present = FactoryBot.create(:user)
      FactoryBot.create(:group_member, user: @already_present, group: @group)
      sign_in @primary_mentor
    end

    context "when primary_mentor is logged in" do
      it "creates members that are not present and pending invitations for others" do
        expect do
          post group_members_path, params: create_params
        end.to change(GroupMember, :count).by(1)
                                          .and change(PendingInvitation, :count).by(1)
      end
    end

    context "when a mentor is logged in" do
      it "throws unauthorized error" do
        sign_in_group_mentor(@group)
        post group_members_path, params: create_params
        check_not_authorized(response)
      end
    end

    context "when user other than primary_mentor is logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        post group_members_path, params: create_params
        check_not_authorized(response)
      end
    end
  end

  describe "#update" do
    before do
      @group_member = FactoryBot.create(:group_member, user: FactoryBot.create(:user),
                                                       group: @group)
    end

    context "when primary_mentor is signed in" do
      it "updates group member" do
        sign_in @primary_mentor
        expect do
          patch group_member_path(@group_member), params: { group_member: { mentor: true } }
        end.to change { @group_member.reload.mentor }.from(false).to(true)
      end
    end

    context "when a mentor is signed in" do
      it "throws unauthorized error" do
        sign_in_group_mentor(@group)
        patch group_member_path(@group_member), params: { group_member: { mentor: true } }
        check_not_authorized(response)
      end
    end

    context "when user other than the primary_mentor is logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        patch group_member_path(@group_member), params: { group_member: { mentor: true } }
        check_not_authorized(response)
      end
    end
  end

  describe "#destroy" do
    before do
      @group_member = FactoryBot.create(:group_member, user: FactoryBot.create(:user),
                                                       group: @group)
    end

    context "when primary_mentor is signed in" do
      it "destroys group member" do
        sign_in @primary_mentor
        expect do
          delete group_member_path(@group_member)
        end.to change(GroupMember, :count).by(-1)
      end
    end

    context "when a mentor is signed in" do
      it "throws unauthorized error" do
        sign_in_group_mentor(@group)
        delete group_member_path(@group_member)
        check_not_authorized(response)
      end
    end

    context "when user other than the primary_mentor is logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        delete group_member_path(@group_member)
        check_not_authorized(response)
      end
    end
  end
end
