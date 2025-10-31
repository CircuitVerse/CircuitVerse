# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:submissions) }
    it { is_expected.to have_many(:submission_votes) }
    it { is_expected.to have_one(:contest_winner) }
  end

  # === Tests for Name Defaulting and Normalization ===
  describe "Name Defaulting and Normalization" do
    # Calculate the max ID before tests run to correctly predict the placeholder name
    let!(:max_id_before) { described_class.unscoped.maximum(:id).to_i }
    let(:expected_placeholder_id) { max_id_before + 1 }

    context "when a contest is created without a name" do
      it "sets a placeholder name before validation to pass presence check" do
        contest = described_class.new(deadline: 1.month.from_now, status: :live)
        contest.valid? # Triggers before_validation

        expect(contest.name).to eq("Contest ##{expected_placeholder_id}")
        expect(contest.instance_variable_get(:@default_name_assigned)).to be(true)
      end

      it "normalizes the name to use the final record ID after commit" do
        contest = described_class.create!(deadline: 1.month.from_now, status: :live)

        expect(contest.reload.name).to eq("Contest ##{contest.id}")

        expect(contest.name).to eq("Contest ##{described_class.last.id}") if contest.id != expected_placeholder_id
      end
    end

    context "when a contest is created with a custom name" do
      it "retains the custom name and skips normalization" do
        custom_name = "My Test Challenge"
        contest = create(:contest, name: custom_name, deadline: 1.month.from_now, status: :live)

        expect(contest.reload.name).to eq(custom_name)

        expect(contest.instance_variable_defined?(:@default_name_assigned)).to be(false)
      end
    end
  end
end
