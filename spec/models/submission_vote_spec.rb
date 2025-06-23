# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubmissionVote, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:submission) }
    it { is_expected.to belong_to(:contest) }
  end
end
