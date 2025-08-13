# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Explore", type: :request do
  around do |ex|
    Flipper.disable(:circuit_explore_page)
    ex.run
    Flipper.disable(:circuit_explore_page)
  end

  it "404 when flag disabled" do
    expect { get "/explore" }.to raise_error(ActionController::RoutingError)
  end

  it "200 when flag enabled" do
    Flipper.enable(:circuit_explore_page)
    get "/explore"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t("explore.main_heading"))
  end
end
