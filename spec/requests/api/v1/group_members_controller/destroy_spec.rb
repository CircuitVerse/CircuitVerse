# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GroupMembersController, "#destroy", type: :request do
  describe "delete specific group members" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }
    let!(:group_member) { FactoryBot.create(:group_member, group: group, user: user) }

    context "when not authenticated" do
      before do
        delete "/api/v1/group/members/#{group_member.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as random user and don't have edit_access?" do
      before do
        token = get_auth_token(user)
        delete "/api/v1/group/members/#{group_member.id}",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but tries to delete non existent group member" do
      before do
        token = get_auth_token(primary_mentor)
        delete "/api/v1/group/members/0",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated and has access to delete group member" do
      before do
        token = get_auth_token(primary_mentor)
        delete "/api/v1/group/members/#{group_member.id}",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "delete group & return status no_content" do
        expect { GroupMember.find(group_member.id) }.to raise_exception(
          ActiveRecord::RecordNotFound
        )
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
