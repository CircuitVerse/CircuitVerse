# frozen_string_literal: true

require "rails_helper"

RSpec.describe Subgroup, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:group) }
  end

  describe "validations" do
    let(:group) { FactoryBot.create(:group) }

    it "is valid with valid attributes" do
      subgroup = Subgroup.new(name: "Subgroup A", group: group)
      expect(subgroup).to be_valid
    end

    it "is invalid without a name" do
      subgroup = Subgroup.new(name: nil, group: group)
      expect(subgroup).not_to be_valid
    end

    it "is invalid without a group" do
      subgroup = Subgroup.new(name: "Subgroup A", group: nil)
      expect(subgroup).not_to be_valid
    end
  end
end
 
