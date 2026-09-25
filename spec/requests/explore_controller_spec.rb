# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore", type: :request do
  it "renders explore page" do
    get "/explore"
    expect(response.status).to eq(200)
    expect(response.body).to include("Circuit of the week")
    expect(response.body).to include("Editor Picks")
  end
end
