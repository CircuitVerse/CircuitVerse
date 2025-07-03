# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShortlistContestWinner, "#call — RecordNotUnique branch" do
  let(:contest) { create(:contest, status: :live) }

  before { create(:submission, :with_private_project, contest: contest) }

  it "swallows ActiveRecord::RecordNotUnique and returns success" do
    allow(ContestWinner).to receive(:create!)
      .and_raise(ActiveRecord::RecordNotUnique.new("dup"))
    allow(FeaturedCircuit).to receive(:create!).and_return(true)

    res = described_class.new(contest.id).call

    expect(res[:success]).to be true
    expect(res[:message]).to eq("Winner already recorded by another worker")
  end
end
