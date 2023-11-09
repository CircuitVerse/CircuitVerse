# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeaturedCircuit, type: :model do
  before do
    @user = FactoryBot.create(:user)
  end

  describe "associations" do
    before do
      # hacky solution for bypassing validation
      allow_any_instance_of(described_class).to receive(:project_public).and_return(true)
    end

    it { is_expected.to belong_to(:project) }
  end

  describe "callbacks" do
    it "checks featured projects are public" do
      project = FactoryBot.create(:project, author: @user, project_access_type: "Public")
      featured_circuit = FactoryBot.create(:featured_circuit, project: project)
      expect(featured_circuit).to be_valid
      project.project_access_type = "Private"
      project.save
      expect(featured_circuit).not_to be_valid
    end

    it "sends featured circuit email" do
      project = FactoryBot.create(:project, author: @user, project_access_type: "Public")
      expect do
        FactoryBot.create(:featured_circuit, project: project)
      end.to have_enqueued_job.on_queue("mailers")
    end
  end
end
