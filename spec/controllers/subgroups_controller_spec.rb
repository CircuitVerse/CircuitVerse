# frozen_string_literal: true

require "rails_helper"

describe SubgroupsController, type: :request do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
  end

  describe "#create" do
    context "when the subgroups data layer is not available yet" do
      it "redirects without raising" do
        sign_in @primary_mentor
        post group_subgroups_path(@group), params: { group: { name: "Team A" } }

        expect(response).to redirect_to(group_path(@group))
        expect(flash[:alert]).to eq(I18n.t("subgroups.not_available"))
      end
    end

    context "when a random user is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        post group_subgroups_path(@group), params: { group: { name: "Team A" } }
        check_not_authorized(response)
      end
    end
  end

  describe "#destroy" do
    context "when the subgroups data layer is not available yet" do
      it "redirects without raising" do
        sign_in @primary_mentor
        delete group_subgroup_path(@group, 1)

        expect(response).to redirect_to(group_path(@group))
        expect(flash[:alert]).to eq(I18n.t("subgroups.not_available"))
      end
    end

    context "when a random user is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        delete group_subgroup_path(@group, 1)
        check_not_authorized(response)
      end
    end
  end
end
