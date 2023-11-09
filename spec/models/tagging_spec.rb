# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tagging, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:tag) }
  end
end
