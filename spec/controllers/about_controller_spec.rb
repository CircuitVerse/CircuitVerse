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
      expect(response.body).to include("lang=fr")
    end

    it "handles mixed-case language tags" do
      get about_index_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "FR-fr" }
      expect(response.status).to eq(200)
      expect(response.body).to include("lang=fr")
    end

    it "selects supported locale when an unsupported preference precedes it" do
      get about_index_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "zz, fr;q=0.8" }
      expect(response.status).to eq(200)
      expect(response.body).to include("lang=fr")
    end

    it "falls back to default locale for an unsupported header language" do
      get about_index_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "xx" }
      expect(response.status).to eq(200)
      expect(response.body).to include("lang=en")
    end

    it "falls back to default locale when Accept-Language header is missing" do
      get about_index_path
      expect(response.status).to eq(200)
      expect(response.body).to include("lang=en")
    end
  end
end
