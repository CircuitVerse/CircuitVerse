# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SubgroupsController, "#show", type: :request do
  describe "show a subgroup" do
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: mentor) }
    let!(:subgroup) { FactoryBot.create(:group, name: "Team A", parent_group: group) }

    context "when not authenticated" do
      before { get "/api/v1/subgroups/#{subgroup.id}", as: :json }

      it "returns unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when the mentor requests the subgroup" do
      before do
        token = get_auth_token(mentor)
        get "/api/v1/subgroups/#{subgroup.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns the subgroup details" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"]["attributes"]["name"]).to eq("Team A")
        expect(response.parsed_body["data"]["attributes"]["parent_group_id"]).to eq(group.id)
      end
    end

    context "when a non-member requests the subgroup" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        get "/api/v1/subgroups/#{subgroup.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when the id belongs to a top-level group" do
      before do
        token = get_auth_token(mentor)
        get "/api/v1/subgroups/#{group.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns not found" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
