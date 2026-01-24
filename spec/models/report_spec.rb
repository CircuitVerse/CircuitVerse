# frozen_string_literal: true

require "rails_helper"

RSpec.describe Report, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:reporter).class_name("User") }
    it { is_expected.to belong_to(:reported_user).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:reason) }
    it { is_expected.to validate_presence_of(:status) }
  end
end
