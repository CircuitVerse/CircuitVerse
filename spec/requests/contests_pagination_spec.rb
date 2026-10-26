# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests pagination", type: :request do
  before { create(:contest) }

  it "renders the first page" do
    get contests_path

    expect(response).to have_http_status(:ok)
  end

  it "returns not found for a non-numeric page" do
    get contests_path, params: { page: "abc" }

    expect(response).to have_http_status(:not_found)
  end

  it "returns not found for page zero" do
    get contests_path, params: { page: 0 }

    expect(response).to have_http_status(:not_found)
  end
end
