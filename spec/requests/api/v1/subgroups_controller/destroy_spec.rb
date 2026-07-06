# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SubgroupsController, "#destroy", type: :request do
  describe "delete a subgroup" do
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: mentor) }
    let!(:subgroup) { FactoryBot.create(:group, name: "Team A", parent_group: group) }

    context "when not authenticated" do
      before { delete "/api/v1/subgroups/#{subgroup.id}", as: :json }

      it "returns unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when a regular member tries to delete the subgroup" do
      before do
        member = FactoryBot.create(:user)
        FactoryBot.create(:group_member, group: group, user: member)
        token = get_auth_token(member)
        delete "/api/v1/subgroups/#{subgroup.id}",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns forbidden and keeps the subgroup" do
        expect(response).to have_http_status(:forbidden)
        expect(Group.exists?(subgroup.id)).to be(true)
      end
    end

    context "when the mentor deletes the subgroup" do
      before do
        token = get_auth_token(mentor)
        delete "/api/v1/subgroups/#{subgroup.id}",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "deletes the subgroup" do
        expect(response).to have_http_status(:no_content)
        expect(Group.exists?(subgroup.id)).to be(false)
      end
    end

    context "when the id belongs to a top-level group" do
      before do
        token = get_auth_token(mentor)
        delete "/api/v1/subgroups/#{group.id}",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns not found" do
        expect(response).to have_http_status(:not_found)
        expect(Group.exists?(group.id)).to be(true)
      end
    end
  end
end
