# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore", type: :request do
  around do |ex|
    Flipper.disable(:circuit_explore_page)
    ex.run
    Flipper.disable(:circuit_explore_page)
  end

  it "redirects when flag disabled" do
    get "/explore"
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(root_path)
  end

  it "200 when flag enabled" do
    Flipper.enable(:circuit_explore_page)
    get "/explore"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t("explore.main_heading"))
  end
end
