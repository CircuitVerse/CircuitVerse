# frozen_string_literal: true

require "rails_helper"

RSpec.describe PushSubscription, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end
end
