# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GroupsController, "#groups_mentored", type: :request do
  describe "list all groups mentored" do
    let!(:mentor) { FactoryBot.create(:user) }

    context "when not authenticated" do
      before do
        get "/api/v1/groups/mentored", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as mentor and including assignments" do
      before do
        # create 3 groups with assignments and group_members for each
        FactoryBot.create_list(:group, 3, mentor: mentor).each do |g|
          FactoryBot.create(:assignment, group: g)
        end
        token = get_auth_token(mentor)
        get "/api/v1/groups/mentored?include=assignments",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all groups including assignments signed in user mentors" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("groups_with_assignments")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end

    context "when authenticated as mentor and including group_members" do
      before do
        # create 3 groups with 4 group_members for each
        FactoryBot.create_list(:group, 3, mentor: mentor).each do |g|
          # creates three random group members
          # rubocop:disable FactoryBot/CreateList
          3.times do
            FactoryBot.create(:group_member, group: g, user: FactoryBot.create(:user))
          end
          # rubocop:enable FactoryBot/CreateList
        end
        token = get_auth_token(mentor)
        get "/api/v1/groups/mentored?include=group_members",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all groups including group_members signed in user mentors" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("groups_with_members")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end
  end
end
