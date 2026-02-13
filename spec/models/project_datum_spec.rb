# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectDatum, type: :model do
  let(:project) { create(:project) }

  it "is valid with valid data" do
    datum = ProjectDatum.new(project: project, data: { "scopes" => [] })
    expect(datum).to be_valid
  end

  it "rejects oversized payload" do
    large_data = "a" * (6.megabytes)
    datum = ProjectDatum.new(project: project, data: large_data)

    expect(datum).not_to be_valid
    expect(datum.errors[:data]).to include("Payload exceeds 5MB limit")
  end

  it "rejects invalid JSON" do
    datum = ProjectDatum.new(project: project, data: "invalid json")

    expect(datum).not_to be_valid
  end

  it "rejects JSON without scopes key" do
    datum = ProjectDatum.new(project: project, data: { "foo" => "bar" })

    expect(datum).not_to be_valid
  end
end
