# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest, type: :model do
  # ... (associations block remains the same) ...

  # === Tests for Name Defaulting and Normalization ===
  describe "Name Defaulting and Normalization" do
    # FIX: No need for unreliable 'let!' blocks to predict IDs.

    context "when a contest is created without a name" do
      it "sets a placeholder name before validation to pass presence check" do
        contest = described_class.new(deadline: 1.month.from_now, status: :live)
        contest.valid? # Triggers before_validation
        expect(contest.name).to start_with("Contest #")
        
      end

      it "normalizes the name to use the final record ID after commit" do
        contest = described_class.create!(deadline: 1.month.from_now, status: :live)
        expect(contest.reload.name).to eq("Contest ##{contest.id}")
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
