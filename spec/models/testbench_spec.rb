# frozen_string_literal: true

require "rails_helper"

RSpec.describe Testbench, type: :model do
  subject { FactoryBot.create(:testbench) }

  def build_with(data)
    FactoryBot.build(:testbench, data: data)
  end

  def with_group(overrides)
    group = FactoryBot.build(:testbench).data["groups"].first.merge(overrides)
    FactoryBot.build(:testbench).data.merge("groups" => [group])
  end

  it { is_expected.to belong_to(:assignment) }
  it { is_expected.to validate_uniqueness_of(:assignment_id) }

  it "accepts a suite the simulator can run" do
    expect(FactoryBot.build(:testbench)).to be_valid
  end

  it "accepts a sequential suite" do
    expect(build_with(FactoryBot.build(:testbench).data.merge("type" => "seq"))).to be_valid
  end

  it "rejects a suite that is not an object" do
    expect(build_with(["AndGate"])).not_to be_valid
  end

  it "rejects a type the simulator does not run" do
    expect(build_with(FactoryBot.build(:testbench).data.merge("type" => "verilog"))).not_to be_valid
  end

  it "rejects a suite with no groups" do
    expect(build_with(FactoryBot.build(:testbench).data.merge("groups" => []))).not_to be_valid
  end

  it "rejects a group with no case count" do
    expect(build_with(with_group("n" => 0))).not_to be_valid
  end

  it "rejects a group with no outputs to compare" do
    expect(build_with(with_group("outputs" => []))).not_to be_valid
  end

  it "rejects a signal without a label to bind to the circuit" do
    expect(build_with(with_group("inputs" => [{ "bitWidth" => 1, "values" => %w[0 1] }]))).not_to be_valid
  end

  it "rejects a signal without a bit width" do
    expect(build_with(with_group("inputs" => [{ "label" => "inp1", "values" => %w[0 1] }]))).not_to be_valid
  end

  it "rejects a signal with fewer values than the group has cases" do
    short = { "label" => "out1", "bitWidth" => 1, "values" => %w[0] }
    expect(build_with(with_group("outputs" => [short]))).not_to be_valid
  end

  it "names the signal that is short so the author can fix it" do
    short = { "label" => "carry", "bitWidth" => 1, "values" => [] }
    testbench = build_with(with_group("outputs" => [short]))
    testbench.validate

    expect(testbench.errors[:data]).to include("carry needs 2 values")
  end

  it "exposes the groups the autograder runs" do
    expect(subject.groups.first["n"]).to eq(2)
  end
end
