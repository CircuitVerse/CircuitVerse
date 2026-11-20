# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Error pages", type: :request do
  it "keeps the requested locale when rendering the 404 page" do
    get "/users/99999", params: { locale: "fr" }

    expect(response).to have_http_status(:not_found)
    expect(Nokogiri::HTML(response.body).at_css("html")["lang"]).to eq("fr")
  end

  it "links back to the local homepage instead of production" do
    get "/users/99999"

    expect(response).to have_http_status(:not_found)
    expect(response.body).not_to include('href="https://circuitverse.org/" class="return')
  end
end
