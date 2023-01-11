# frozen_string_literal: true

require "rails_helper"

RSpec.describe I18nSupport, type: :service do
  describe "#locale_names" do
    it "returns array of locale names and codes" do
      expect(described_class.locale_names).to eq([%w[English en], %w[Hindi hi]])
    end
  end
end
