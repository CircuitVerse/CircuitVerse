# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestWinner, type: :model do
  describe "associations" do
# spec/models/contest_winner.rb

-    it { is_expected.to belongs_to(:submissions) }
+    it { is_expected.to belongs_to(:submission) }
    it { is_expected.to belongs_to(:project) }
    it { is_expected.to belongs_to(:contest) }
  end
end
