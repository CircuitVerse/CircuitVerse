# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:taggings) }
    it { is_expected.to have_many(:projects) }
  end

  describe "validations" do
    subject { FactoryBot.create(:tag) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe "name normalization" do
    it "strips surrounding whitespace" do
      tag = described_class.create!(name: "  verilog  ")
      expect(tag.name).to eq("verilog")
    end
  end

  describe ".named" do
    it "finds tags regardless of case" do
      tag = described_class.create!(name: "Counter")
      expect(described_class.named("cOuNtEr")).to eq(tag)
    end

    it "returns nil when no tag matches" do
      expect(described_class.named("missing")).to be_nil
    end
  end

  describe ".find_or_create_with_name!" do
    it "returns the existing tag when name differs only by case" do
      tag = described_class.create!(name: "ALU")
      expect do
        expect(described_class.find_or_create_with_name!("alu")).to eq(tag)
      end.not_to change(described_class, :count)
    end

    it "creates a new tag when none exists" do
      expect do
        described_class.find_or_create_with_name!("decoder")
      end.to change(described_class, :count).by(1)
    end
  end

  describe "database constraints" do
    it "rejects duplicate names differing only by case at the db level" do
      described_class.create!(name: "Adder")
      duplicate = described_class.new(name: "adder")
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
