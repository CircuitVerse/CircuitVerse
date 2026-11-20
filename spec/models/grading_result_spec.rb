# frozen_string_literal: true

require "rails_helper"

RSpec.describe GradingResult, type: :model do
  it { is_expected.to belong_to(:project) }
  it { is_expected.to validate_presence_of(:suite_snapshot) }

  it "rejects a score outside 0..100" do
    result = FactoryBot.build(:grading_result, score: 150)
    expect(result).not_to be_valid
  end

  it "allows a nil score" do
    result = FactoryBot.build(:grading_result, score: nil)
    expect(result).to be_valid
  end
end
