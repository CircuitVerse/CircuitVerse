# frozen_string_literal: true

require "rails_helper"

describe AboutController, type: :request do
  it "gets about page" do
    get about_index_path
    expect(response.status).to eq(200)
  end

  describe "locale selection from Accept-Language header" do
    it "sets locale to the supported header language" do
      get about_index_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "fr" }
      expect(response.status).to eq(200)
      expect(I18n.locale).to eq(:fr)
    end

    it "falls back to default locale for an unsupported header language" do
      get about_index_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "zh" }
      expect(response.status).to eq(200)
      expect(I18n.locale).to eq(:en)
    end
  end
end
