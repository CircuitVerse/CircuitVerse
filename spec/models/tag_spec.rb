# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "associations" do
    it { should have_many(:taggings) }
    it { should have_many(:projects) }
  end
end
