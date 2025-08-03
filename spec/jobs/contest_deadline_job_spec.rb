# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestDeadlineJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let(:contest) { create(:contest, status: :live, deadline: 5.minutes.from_now) }
  let(:submission) { create(:submission, :with_private_project, contest: contest) }

  before do
    submission
    allow(FeaturedCircuit).to receive(:create!).and_return(true)
  end

  after { travel_back }

  it "completes the contest and invokes ShortlistContestWinner" do
    travel_to 10.minutes.from_now do
      described_class.perform_now(contest.id)
    end

    expect(contest.reload.status).to eq("completed")
    expect(ContestWinner.exists?(contest: contest)).to be true
  end

  it "early-returns if contest already completed" do
    contest.update!(status: :completed)

    expect { described_class.perform_now(contest.id) }
      .not_to(change { contest.reload.updated_at })
  end

  context "when deadline not reached" do
    before { contest.update!(status: :live, deadline: 1.day.from_now) }

    it "does nothing" do
      expect { described_class.perform_now(contest.id) }
        .not_to(change(ContestWinner, :count))
    end
  end

  context "when contest is completed before job runs" do
    before { contest.update!(status: :completed, deadline: 1.day.ago) }

    it "does nothing" do
      expect { described_class.perform_now(contest.id) }
        .not_to(change(ContestWinner, :count))
    end
  end
end
