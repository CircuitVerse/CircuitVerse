# frozen_string_literal: true

require "rails_helper"

RSpec.describe AutogradeJob, type: :job do
  let(:group) { FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user)) }
  let(:assignment) { FactoryBot.create(:assignment, group: group) }
  let(:project) { FactoryBot.create(:project_datum).project }
  let(:suite) do
    { "type" => "comb",
      "groups" => [{ "n" => 2,
                     "inputs" => [{ "label" => "inp1", "bitWidth" => 1, "values" => %w[0 1] }],
                     "outputs" => [{ "label" => "out1", "bitWidth" => 1, "values" => %w[0 1] }] }] }
  end
  let(:endpoint) { "http://127.0.0.1:3050/run" }
  let(:results) { { "groups" => [{ "cases" => [{ "passed" => true }, { "passed" => false }] }] } }

  before { project.update!(assignment: assignment) }

  it "does nothing without a testbench" do
    described_class.perform_now(project.id)
    expect(GradingResult.count).to eq(0)
  end

  context "with a testbench" do
    before { FactoryBot.create(:testbench, assignment: assignment, data: suite) }

    it "writes a GradingResult with the runner's score" do
      stub_request(:post, endpoint).to_return(body: results.to_json)
      described_class.perform_now(project.id)

      result = GradingResult.last
      expect(result.project).to eq(project)
      expect(result.score).to eq(50.0)
    end

    it "writes a failed GradingResult when the runner is unreachable" do
      stub_request(:post, endpoint).to_timeout
      described_class.perform_now(project.id)

      expect(GradingResult.last.score).to be_nil
    end

    it "stops once max_attempts is reached" do
      assignment.update!(max_attempts: 1)
      FactoryBot.create(:grading_result, project: project)
      stub_request(:post, endpoint).to_return(body: results.to_json)

      expect { described_class.perform_now(project.id) }.not_to change(GradingResult, :count)
    end
  end
end
