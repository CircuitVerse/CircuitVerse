# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "pagy_bootstrap_nav translations" do
    def nav_in(locale)
      I18n.with_locale(locale) { helper.pagy_bootstrap_nav(Pagy.new(count: 30, page: 2, limit: 10)) }
    end

    it "uses English labels by default" do
      expect(nav_in(:en)).to include('aria-label="Previous"', 'aria-label="Next"')
    end

    it "uses pagy's bundled translations for supported locales" do
      expect(nav_in(:fr)).to include('aria-label="Précédent"', 'aria-label="Suivant"')
    end

    it "uses the app's translations for locales pagy does not ship" do
      expect(nav_in(:hi)).to include('aria-label="पिछला"', 'aria-label="अगला"')
    end

    it "falls back to English for locales without a translation" do
      expect(nav_in(:ml)).to include('aria-label="Previous"', 'aria-label="Next"')
    end
  end
end
