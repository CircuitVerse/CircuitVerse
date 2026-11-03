# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SubgroupsController, type: :request do
  let(:primary_mentor) { FactoryBot.create(:user) }
  let(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }
  let(:subgroup) { FactoryBot.create(:group, name: "Team A", parent_group: group) }
  let(:student) { FactoryBot.create(:user) }
  let(:outsider) { FactoryBot.create(:user) }

  def headers_for(user)
    { Authorization: "Token #{get_auth_token(user)}" }
  end

  before { FactoryBot.create(:group_member, group: group, user: student) }

  describe "GET /api/v1/groups/:group_id/subgroups" do
    before { subgroup }

    it "returns 401 when not authenticated" do
      get "/api/v1/groups/#{group.id}/subgroups", as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 for a user outside the group" do
      get "/api/v1/groups/#{group.id}/subgroups", headers: headers_for(outsider), as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "lists the subgroups for a group member" do
      get "/api/v1/groups/#{group.id}/subgroups", headers: headers_for(student), as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].pluck("id")).to eq([subgroup.id.to_s])
    end
  end

  describe "GET /api/v1/subgroups/:id" do
    it "returns the subgroup to one of its members" do
      FactoryBot.create(:group_member, group: subgroup, user: student)
      get "/api/v1/subgroups/#{subgroup.id}", headers: headers_for(student), as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("data", "id")).to eq(subgroup.id.to_s)
    end

    it "returns 403 to a parent member outside the subgroup" do
      get "/api/v1/subgroups/#{subgroup.id}", headers: headers_for(student), as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 404 for a top-level group id" do
      get "/api/v1/subgroups/#{group.id}", headers: headers_for(primary_mentor), as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/groups/:group_id/subgroups" do
    it "creates a subgroup for the primary mentor" do
      expect do
        post "/api/v1/groups/#{group.id}/subgroups", params: { subgroup: { name: "Team B" } },
                                                     headers: headers_for(primary_mentor), as: :json
      end.to change(group.subgroups, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns 403 for a plain member" do
      post "/api/v1/groups/#{group.id}/subgroups", params: { subgroup: { name: "Team B" } },
                                                   headers: headers_for(student), as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 for a blank name" do
      post "/api/v1/groups/#{group.id}/subgroups", params: { subgroup: { name: "" } },
                                                   headers: headers_for(primary_mentor), as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /api/v1/subgroups/:id" do
    it "deletes the subgroup for the primary mentor" do
      delete "/api/v1/subgroups/#{subgroup.id}", headers: headers_for(primary_mentor), as: :json
      expect(response).to have_http_status(:no_content)
      expect(Group.exists?(subgroup.id)).to be(false)
    end

    it "returns 403 for a plain member" do
      delete "/api/v1/subgroups/#{subgroup.id}", headers: headers_for(student), as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/subgroups/:id/members" do
    it "syncs parent group members into the subgroup" do
      patch "/api/v1/subgroups/#{subgroup.id}/members", params: { user_ids: [student.id, outsider.id] },
                                                        headers: headers_for(primary_mentor), as: :json
      expect(response).to have_http_status(:accepted)
      expect(subgroup.group_members.pluck(:user_id)).to contain_exactly(student.id)
    end

    it "returns 403 for a plain member" do
      patch "/api/v1/subgroups/#{subgroup.id}/members", params: { user_ids: [student.id] },
                                                        headers: headers_for(student), as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end
end
