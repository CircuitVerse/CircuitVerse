# frozen_string_literal: true

require "rails_helper"

RSpec.describe CustomMail, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:sender) }
  end
end
