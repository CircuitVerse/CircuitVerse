# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collaboration do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
  end
end
