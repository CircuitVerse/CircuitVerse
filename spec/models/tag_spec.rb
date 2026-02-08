# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:taggings) }
    it { is_expected.to have_many(:projects) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(1) }

    describe "uniqueness" do
      subject { FactoryBot.create(:tag) }

      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    end
  end
end
