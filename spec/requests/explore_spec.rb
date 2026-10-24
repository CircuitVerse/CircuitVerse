# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore", type: :request do
  it "renders explore page with 200" do
    get "/explore"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Explore Circuits")
  end
end
