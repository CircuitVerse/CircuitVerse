# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectDatum, type: :model do
  it "Has valid spec" do
    expect(create(:project)).to be_valid
  end
end
