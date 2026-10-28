# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Locale switching", type: :request do
  def rendered_lang
    response.body[/<html lang=(\w+)/, 1]
  end

  describe "locale selection" do
    it "uses the locale from the query parameter" do
      get about_index_path, params: { locale: "fr" }

      expect(response).to have_http_status(:ok)
      expect(rendered_lang).to eq("fr")
    end

    it "uses the locale of the signed in user when no parameter is given" do
      sign_in create(:user, locale: "hi")

      get about_index_path

      expect(rendered_lang).to eq("hi")
    end

    it "prefers the query parameter over the user locale" do
      sign_in create(:user, locale: "hi")

      get about_index_path, params: { locale: "fr" }

      expect(rendered_lang).to eq("fr")
    end

    it "falls back to the default locale for an unsupported parameter" do
      get about_index_path, params: { locale: "zz" }

      expect(rendered_lang).to eq("en")
    end

    it "keeps the default locale for an unsupported parameter when signed in" do
      sign_in create(:user, locale: "hi")

      get about_index_path, params: { locale: "zz" }

      expect(rendered_lang).to eq("en")
    end

    it "ignores a non scalar locale parameter" do
      get about_index_path, params: { locale: %w[fr] }

      expect(response).to have_http_status(:ok)
      expect(rendered_lang).to eq("en")
    end
  end
end
