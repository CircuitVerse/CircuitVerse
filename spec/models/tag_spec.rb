# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:taggings) }
    it { is_expected.to have_many(:projects) }
  end
end
