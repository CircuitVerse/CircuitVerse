# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestPolicy do
  subject(:policy) { described_class.new(user, contest) }

  let(:contest) { build(:contest) }

  context "with a logged-in user" do
    let(:user) { build(:user) }

    it "permits leaderboard access" do
      expect(policy.leaderboard?).to be true
    end
  end

  context "with a guest (nil user)" do
    let(:user) { nil }

    it "denies leaderboard access" do
      expect(policy.leaderboard?).to be false
    end
  end
end
