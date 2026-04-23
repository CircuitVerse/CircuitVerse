# frozen_string_literal: true

require "rails_helper"

RSpec.describe "I18n locale keys", type: :i18n do
  describe "assignments translations" do
    it "has create success message" do
      expect(I18n.t("assignments.create.success")).to eq("Assignment was successfully created.")
    end

    it "has update success message" do
      expect(I18n.t("assignments.update.success")).to eq("Assignment was successfully updated.")
    end

    it "has destroy success message" do
      expect(I18n.t("assignments.destroy.success")).to eq("Assignment was successfully deleted.")
    end
  end

  describe "collaborations translations" do
    it "has update success message" do
      expect(I18n.t("collaborations.update.success")).to eq("Collaboration was successfully updated.")
    end

    it "has destroy success message" do
      expect(I18n.t("collaborations.destroy.success")).to eq("Collaboration was successfully removed.")
    end
  end
end
