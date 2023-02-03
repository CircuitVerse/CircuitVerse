# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GroupsController, "#groups_owned", type: :request do
  describe "list all groups owned" do
    let!(:primary_mentor) { FactoryBot.create(:user) }

    context "when not authenticated" do
      before do
        get "/api/v1/groups/owned", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as primary_mentor and including assignments" do
      before do
        # create 3 groups with assignments and group_members for each
        FactoryBot.create_list(:group, 3, primary_mentor: primary_mentor).each do |g|
          FactoryBot.create(:assignment, group: g)
        end
        token = get_auth_token(primary_mentor)
        get "/api/v1/groups/owned?include=assignments",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns all groups including assignments signed in user owns" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("groups_with_assignments")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end

    context "when authenticated as primary_mentor and including group_members" do
      before do
        # create 3 groups with 4 group_members for each
        FactoryBot.create_list(:group, 3, primary_mentor: primary_mentor).each do |g|
          # creates three random group members
          # rubocop:disable RSpec/FactoryBot/CreateList
          3.times do
            FactoryBot.create(:group_member, group: g, user: FactoryBot.create(:user))
          end
          # rubocop:enable RSpec/FactoryBot/CreateList
        end
        token = get_auth_token(primary_mentor)
        get "/api/v1/groups/owned?include=group_members",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns all groups including group_members signed in user owns" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("groups_with_members")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end
  end
end
