# frozen_string_literal: true

require "rails_helper"

RSpec.describe GradingResultsHelper, type: :helper do
  describe "#visible_test_groups" do
    let(:breakdown) do
      [{ "label" => "Case 1", "cases" => [{ "passed" => true }, { "passed" => false }] }]
    end
    let(:snapshot) do
      { "groups" => [{ "inputs" => [{ "label" => "a", "values" => ["0", "1"] }],
                       "outputs" => [{ "label" => "out", "values" => ["0", "0"] }] }] }
    end
    let(:result) { FactoryBot.build(:grading_result, breakdown: breakdown, suite_snapshot: snapshot) }

    it "renders one row per case instead of collapsing the group" do
      rows = helper.visible_test_groups(result, false)

      expect(rows.size).to eq(2)
      expect(rows.map { |r| r["passed"] }).to eq([true, false])
      expect(rows[0]["inputs"].first["values"]).to eq(["0"])
      expect(rows[1]["inputs"].first["values"]).to eq(["1"])
    end
  end
end
