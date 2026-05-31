# frozen_string_literal: true

require "rails_helper"

RSpec.describe Submission, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:contest) }
    it { is_expected.to have_many(:submission_votes) }
    it { is_expected.to have_one(:contest_winner) }
  end
end
