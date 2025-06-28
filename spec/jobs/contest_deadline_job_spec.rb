# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestDeadlineJob, type: :job do
  let(:contest) { create(:contest, status: :live, deadline: 1.day.ago) }

  it "completes the contest and invokes ShortlistContestWinner" do
    described_class.perform_now(contest.id)
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
