# frozen_string_literal: true

require "rails_helper"

RSpec.describe Autograder::Runner do
  let(:suite) do
    { "type" => "comb",
      "groups" => [{ "n" => 2,
                     "inputs" => [{ "label" => "inp1", "bitWidth" => 1, "values" => %w[0 1] }],
                     "outputs" => [{ "label" => "out1", "bitWidth" => 1, "values" => %w[0 1] }] }] }
  end
  let(:testbench) { Struct.new(:data).new(suite) }
  let(:project) { FactoryBot.create(:project_datum).project }
  let(:endpoint) { "http://127.0.0.1:3050/run" }
  let(:results) do
    { "groups" => [{ "label" => "Group 1",
                     "cases" => [{ "index" => 0, "passed" => true },
                                 { "index" => 1, "passed" => false }] }] }
  end

  def stub_runner(status: 200, body: results.to_json)
    stub_request(:post, endpoint).to_return(status: status, body: body)
  end

  def run
    described_class.call(project: project, testbench: testbench)
  end

  it "sends the circuit and the suite to the runner" do
    stub_runner
    run

    sent = a_request(:post, endpoint).with do |req|
      JSON.parse(req.body)["testbench"]["type"] == "comb"
    end
    expect(sent).to have_been_made
  end

  it "counts every case across the groups" do
    stub_runner

    expect(run.total).to eq(2)
    expect(run.passed).to eq(1)
  end

  it "scores the run as the fraction of cases passed" do
    stub_runner

    expect(run.score).to eq(0.5)
  end

  it "keeps the per-case breakdown for the results view" do
    stub_runner

    expect(run.groups.first["cases"].last["passed"]).to be false
  end

  it "raises when the project has no circuit to run" do
    expect { described_class.call(project: FactoryBot.create(:project), testbench: testbench) }
      .to raise_error(described_class::RunnerError, /no runnable circuit/)
  end

  it "raises when the runner rejects the request" do
    stub_runner(status: 500)

    expect { run }.to raise_error(described_class::RunnerError, /500/)
  end

  it "raises when the runner is unreachable" do
    stub_request(:post, endpoint).to_timeout

    expect { run }.to raise_error(described_class::RunnerError, /unreachable/)
  end

  it "raises when the runner returns something that is not JSON" do
    stub_runner(body: "<html>502</html>")

    expect { run }.to raise_error(described_class::RunnerError, /invalid JSON/)
  end

  it "raises when the runner reports no groups" do
    stub_runner(body: { "groups" => [] }.to_json)

    expect { run }.to raise_error(described_class::RunnerError, /no results/)
  end
end
