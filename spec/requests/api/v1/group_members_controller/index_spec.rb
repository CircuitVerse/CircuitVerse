# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GroupMembersController, "#index", type: :request do
  describe "list all groups members" do
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, mentor: mentor) }

    context "when not authenticated" do
      before do
        get "/api/v1/groups/#{group.id}/members", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as mentor and has group members" do
      before do
        # create 3 groups members for the defined group
        # rubocop:disable FactoryBot/CreateList
        3.times do
          FactoryBot.create(:group_member, group: group, user: FactoryBot.create(:user))
        end
        # rubocop:enable FactoryBot/CreateList
        token = get_auth_token(mentor)
        get "/api/v1/groups/#{group.id}/members",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all groups members" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("group_members")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end
  end
end
