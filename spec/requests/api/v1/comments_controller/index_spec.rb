# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CommentsController, "#index", type: :request do
  describe "get thread's comments" do
    let!(:creator) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, project_access_type: "Public") }

    context "when not authenticated" do
      before do
        FactoryBot.create_list(
          :commontator_comment, 3, creator: creator, thread: project.commontator_thread
        )
        get "/api/v1/threads/#{project.commontator_thread.id}/comments", as: :json
      end

      it "returns all comments with vote_status to be nil" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("comments")
        expect(response.parsed_body["data"].length).to eq(3)
        response.parsed_body["data"].each { |c| expect(c["attributes"]["vote_status"]).to be_nil }
      end
    end

    context "when authenticated" do
      before do
        token = get_auth_token(creator)
        FactoryBot.create_list(
          :commontator_comment, 3, creator: creator, thread: project.commontator_thread
        )
        get "/api/v1/threads/#{project.commontator_thread.id}/comments",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all comments with vote_status not to be nil" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("comments")
        response.parsed_body["data"].each do |comment|
          expect(comment["attributes"]["vote_status"]).not_to be_nil
        end
      end
    end
  end
end
