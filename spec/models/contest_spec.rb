# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:submissions) }
    it { is_expected.to have_many(:submission_votes) }
    it { is_expected.to have_one(:contest_winner) }
  end
end
