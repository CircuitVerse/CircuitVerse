# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:submissions) }
    it { is_expected.to have_many(:submission_votes) }
    it { is_expected.to have_one(:contest_winner) }
  end

  describe "#display_name" do
    context "when a name is present" do
      it "returns the name" do
        contest = build(:contest)

        contest.define_singleton_method(:name)  { "Summer Showdown" }
        contest.define_singleton_method(:title) { "Ignored Title" }

        expect(contest.display_name).to eq "Summer Showdown"
      end
    end

    context "when name is blank but title is present" do
      it "returns the title" do
        contest = build(:contest)

        contest.define_singleton_method(:name)  { nil }
        contest.define_singleton_method(:title) { "Awesome Contest" }

        expect(contest.display_name).to eq "Awesome Contest"
      end
    end

    context "when both name and title are blank" do
      it "falls back to the default with the id" do
        contest = create(:contest)

        contest.define_singleton_method(:name)  { nil }
        contest.define_singleton_method(:title) { nil }

        expect(contest.display_name).to eq "Weekly Contest ##{contest.id}"
      end
    end
  end
end
