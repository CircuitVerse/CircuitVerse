# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API V1 OAuth access", type: :request do
  let(:user) { create(:user) }
  let(:application) { Doorkeeper::Application.create!(name: "Test App", redirect_uri: "https://app.example.com/callback") }

  def create_access_token(resource_owner: user, scopes: "public profile email")
    Doorkeeper::AccessToken.create!(
      resource_owner_id: resource_owner.id,
      application_id: application.id,
      scopes: scopes,
      expires_in: 2.hours.from_now.to_i
    )
  end

  def auth_header(token)
    { "Authorization" => "Bearer #{token.token}" }
  end

  describe "using a Doorkeeper access token" do
    let(:access_token) { create_access_token }

    it "accesses the /api/v1/me endpoint" do
      get "/api/v1/me", headers: auth_header(access_token)

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body.dig("data", "id")).to eq(user.id.to_s)
    end

    it "can create a project" do
      params = {
        name: "API Project",
        data: { "nodes" => [] },
        # Pass an empty data URL so the helper falls back to the default image.
        image: "data:image/jpeg;base64,"
      }

      post "/api/v1/projects", params: params, headers: auth_header(access_token)

      expect(response).to have_http_status(:created)
    end

    it "can list the user's groups" do
      group = create(:group, primary_mentor: user)
      create(:group_member, group: group, user: user)

      get "/api/v1/groups", headers: auth_header(access_token)

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      ids = body.fetch("data").map { |g| g.fetch("id").to_i }
      expect(ids).to include(group.id)
    end
  end
end
