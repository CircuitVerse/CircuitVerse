# frozen_string_literal: true

require "rails_helper"

RSpec.describe MigrateImagePreviewJob, type: :job do
  describe "#perform" do
    it "loads Rails tasks before invoking the Rake task" do
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).with("data:migrate").and_return(instance_double(Rake::Task, invoke: nil))

      job = described_class.new

      job.perform
      expect(Rails.application).to have_received(:load_tasks)
      expect(Rake::Task).to have_received(:[]).with("data:migrate")
    end
  end
end
