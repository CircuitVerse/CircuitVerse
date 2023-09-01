# frozen_string_literal: true

require "rails_helper"
require "redis"

module Maintenance
  RSpec.describe MigrateImagePreviewTask do
    let(:task) { described_class.new }

    describe "#collection" do
      it "returns a collection of projects" do
        expect(task.collection).to be_a(ActiveRecord::Batches::BatchEnumerator)
      end
    end

    describe "#process" do
      it "attaches circuit preview for projects with image_preview attached" do
        # Explicitly declare redis counter to prevent potential errors in local environment
        allow_any_instance_of(Redis).to receive(:get).with("last_migrated_project_id").and_return("0")
        project_with_preview = FactoryBot.create(:project)
        image_file = Rails.root.join("spec/fixtures/files/profile.png").open
        project_with_preview.image_preview = image_file
        project_with_preview.save!
        task.process(Project.all)
        expect(project_with_preview.circuit_preview.attached?).to be(true)
      end

      it "skips circuit_preview for projects with missing image_preview" do
        project_without_preview = FactoryBot.create(:project)
        task.process(Project.all)
        expect(project_without_preview.circuit_preview.attached?).to be(false)
      end
    end

    describe "#count" do
      it "delegates count to collection" do
        create_list(:project, 3)
        expect(task.count).to eq(1)
      end
    end

    describe "#attach_circuit_preview_sidekiq" do
      let(:project) { create(:project) }

      it "attaches circuit_preview to the project" do
        allow_any_instance_of(Redis).to receive(:get).with("last_migrated_project_id").and_return("0")
        image_file = Rails.root.join("spec/fixtures/files/profile.png").open
        project.image_preview = image_file
        expect(project.circuit_preview).to receive(:attach)
        subject.send(:attach_circuit_preview_sidekiq, project)
      end
    end
  end
end
