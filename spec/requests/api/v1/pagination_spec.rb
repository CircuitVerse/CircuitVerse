# frozen_string_literal: true

require "rails_helper"

# paginate() is shared by every paginated endpoint and the guard lives there, so
# the scalar case is pinned on more than the search action.
RSpec.describe "scalar page parameter", type: :request do
  let(:user) { FactoryBot.create(:user) }

  before do
    FactoryBot.create_list(:project, 2, project_access_type: "Public")
    FactoryBot.create_list(:user, 2)
  end

  it "is ignored on the projects index" do
    get "/api/v1/projects?page=2", as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"].length).to eq(2)
  end

  it "is ignored on the users index" do
    get "/api/v1/users?page=2", headers: { Authorization: "Token #{get_auth_token(user)}" }, as: :json

    expect(response).to have_http_status(:ok)
  end
end
