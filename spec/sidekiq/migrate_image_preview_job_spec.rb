# frozen_string_literal: true

require "rails_helper"

RSpec.describe MigrateImagePreviewJob, type: :job do
  describe "#perform" do
    let(:rails_application) { Rails.application }
    let(:rake_task) { Rake::Task }

    it "loads Rails tasks before invoking the Rake task" do
      expect(rails_application).to receive(:load_tasks)
      allow(rake_task).to receive(:[]).with("data:migrate").and_return(
        instance_double(rake_task, invoke: nil)
      )
      job = described_class.new

      job.perform
    end
  end
end
