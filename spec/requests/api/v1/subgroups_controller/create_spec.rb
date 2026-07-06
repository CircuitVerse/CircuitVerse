# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SubgroupsController, "#create", type: :request do
  describe "create a subgroup" do
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: mentor) }

    context "when not authenticated" do
      before { post "/api/v1/groups/#{group.id}/subgroups", as: :json }

      it "returns unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when a regular member tries to create a subgroup" do
      before do
        member = FactoryBot.create(:user)
        FactoryBot.create(:group_member, group: group, user: member)
        token = get_auth_token(member)
        post "/api/v1/groups/#{group.id}/subgroups",
             headers: { Authorization: "Token #{token}" },
             params: { subgroup: { name: "Team A" } }, as: :json
      end

      it "returns forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when the mentor creates a subgroup with valid params" do
      before do
        token = get_auth_token(mentor)
        post "/api/v1/groups/#{group.id}/subgroups",
             headers: { Authorization: "Token #{token}" },
             params: { subgroup: { name: "Team A" } }, as: :json
      end

      it "creates the subgroup and inherits the primary mentor" do
        expect(response).to have_http_status(:created)
        subgroup = Group.find(response.parsed_body["data"]["id"])
        expect(subgroup.parent_group).to eq(group)
        expect(subgroup.primary_mentor).to eq(mentor)
      end
    end

    context "when the mentor submits an invalid (duplicate) name" do
      before do
        FactoryBot.create(:group, name: "Team A", parent_group: group)
        token = get_auth_token(mentor)
        post "/api/v1/groups/#{group.id}/subgroups",
             headers: { Authorization: "Token #{token}" },
             params: { subgroup: { name: "Team A" } }, as: :json
      end

      it "returns unprocessable entity with errors" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when the target group is itself a subgroup" do
      before do
        subgroup = FactoryBot.create(:group, name: "Team A", parent_group: group)
        token = get_auth_token(mentor)
        post "/api/v1/groups/#{subgroup.id}/subgroups",
             headers: { Authorization: "Token #{token}" },
             params: { subgroup: { name: "Nested" } }, as: :json
      end

      it "returns forbidden (no nesting)" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
