# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestWinner, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:submission) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:contest) }
  end
end
