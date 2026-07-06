# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SubgroupsController, "#index", type: :request do
  describe "list subgroups of a group" do
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: mentor) }
    let!(:subgroup) { FactoryBot.create(:group, name: "Team A", parent_group: group) }

    context "when not authenticated" do
      before { get "/api/v1/groups/#{group.id}/subgroups", as: :json }

      it "returns unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when a non-member requests the subgroups" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        get "/api/v1/groups/#{group.id}/subgroups",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when the mentor requests the subgroups" do
      before do
        token = get_auth_token(mentor)
        get "/api/v1/groups/#{group.id}/subgroups",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns the subgroups" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].first["id"]).to eq(subgroup.id.to_s)
        expect(response.parsed_body["data"].first["attributes"]["name"]).to eq(subgroup.name)
        expect(response.parsed_body["data"].first["attributes"]["parent_group_id"]).to eq(group.id)
      end
    end
  end
end
