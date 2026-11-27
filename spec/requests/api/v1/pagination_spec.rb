# frozen_string_literal: true

require "rails_helper"

# paginate() is shared by every paginated endpoint and the guard lives there, so
# the scalar case is pinned beyond the projects index, which covers it in its own
# spec. One endpoint here is enough to prove the shared helper behaves.
RSpec.describe "scalar page parameter", type: :request do
  let(:user) { FactoryBot.create(:user) }

  before do
    FactoryBot.create_list(:user, 2)
  end

  it "is ignored on the users index" do
    get "/api/v1/users?page=2", headers: { Authorization: "Token #{get_auth_token(user)}" }, as: :json

    expect(response).to have_http_status(:ok)
    # Three users exist and per-page is 9, so page 1 returns all three and page 2
    # returns none - the count tells "ignored" apart from "honoured".
    expect(response.parsed_body["data"].length).to eq(3)
  end
end
