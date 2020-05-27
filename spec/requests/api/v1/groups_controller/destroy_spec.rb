# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GroupsController, "#destroy", type: :request do
  describe "delete specific group" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, mentor: mentor) }

    context "when not authenticated" do
      before do
        delete "/api/v1/groups/#{group.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and don't have edit_access?" do
      before do
        token = get_auth_token(user)
        delete "/api/v1/groups/#{group.id}",
               headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(403)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to delete non existent group" do
      before do
        token = get_auth_token(mentor)
        delete "/api/v1/groups/0",
               headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(404)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to delete group" do
      before do
        token = get_auth_token(mentor)
        delete "/api/v1/groups/#{group.id}",
               headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "deletes group & return status no_content" do
        expect(response).to have_http_status(204)
      end
    end
  end
end
