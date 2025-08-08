# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest, type: :model do
  describe "deadline_must_be_in_future" do
    it "is invalid when deadline is in the past for a non-completed contest" do
      contest = build(:contest, status: :live, deadline: 1.day.ago)

      expect(contest).not_to be_valid
      expect(contest.errors[:deadline]).to be_present
    end

    it "allows past deadline when contest is completed" do
      contest = build(:contest, status: :completed, deadline: 2.days.ago)

      expect(contest).to be_valid
    end
  end

  describe "only_one_live_contest" do
    it "prevents switching another contest to live when one is already live" do
      create(:contest, status: :live, deadline: 5.days.from_now)

      another = create(:contest, status: :completed, deadline: 6.days.from_now)
      another.status = :live

      expect(another).not_to be_valid
      expect(another.errors[:status]).to be_present
    end

    it "allows creating a completed contest alongside a live contest" do
      create(:contest, status: :live, deadline: 5.days.from_now)

      completed = build(:contest, status: :completed, deadline: 1.day.ago)

      expect(completed).to be_valid
    end

    it "enforces a single live contest at the DB level (unique partial index)" do
      create(:contest, status: :live, deadline: 5.days.from_now)
      another = create(:contest, status: :completed, deadline: 6.days.from_now)

      expect do
        another.update_columns(status: described_class.statuses[:live]) # rubocop:disable Rails/SkipsModelValidations
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
