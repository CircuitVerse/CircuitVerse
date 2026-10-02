# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectDatum, type: :model do
  it "Has valid spec" do
    expect(FactoryBot.create(:project)).to be_valid
  end

  # The test environment uses a :null_store, which never caches anything, so
  # swap in a real store to exercise the caching behaviour.
  around do |example|
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = original
  end

  let!(:project) { FactoryBot.create(:project) }
  let!(:datum) { FactoryBot.create(:project_datum, project: project) }

  describe ".cached_data" do
    it "returns the circuit data for the project" do
      expect(described_class.cached_data(project.id)).to eq(datum.data)
    end

    it "serves the second read from the cache instead of the database" do
      described_class.cached_data(project.id)

      expect(described_class).not_to receive(:find_by)
      expect(described_class.cached_data(project.id)).to eq(datum.data)
    end

    it "returns nil when the project has no circuit data" do
      empty_project = FactoryBot.create(:project)

      expect(described_class.cached_data(empty_project.id)).to be_nil
    end

    it "caches the absence of circuit data rather than re-querying" do
      empty_project = FactoryBot.create(:project)
      described_class.cached_data(empty_project.id)

      expect(described_class).not_to receive(:find_by)
      expect(described_class.cached_data(empty_project.id)).to be_nil
    end

    context "when the cache is unavailable" do
      before do
        allow(Rails.cache).to receive(:fetch).and_raise(Redis::CannotConnectError, "boom")
        allow(Rails.logger).to receive(:warn)
      end

      it "falls back to the database rather than failing the request" do
        expect(described_class.cached_data(project.id)).to eq(datum.data)
      end
    end
  end

  describe "cache invalidation" do
    # Specs run inside a transaction that is rolled back, and this project does
    # not enable run_commit_callbacks, so after_commit never fires here. The
    # hook is exercised directly; the first example covers the wiring.
    it "is registered as an after_commit hook" do
      callbacks = described_class._commit_callbacks.map(&:filter)

      expect(callbacks).to include(:expire_circuit_data_cache)
    end

    it "drops the cached entry when the hook runs" do
      described_class.cached_data(project.id)
      expect(Rails.cache.read(described_class.cache_key(project.id))).to eq(datum.data)

      datum.send(:expire_circuit_data_cache)

      expect(Rails.cache.read(described_class.cache_key(project.id))).to be_nil
    end

    it "does not break the save when the cache cannot be expired" do
      allow(Rails.cache).to receive(:delete).and_raise(Redis::CannotConnectError, "boom")
      allow(Rails.logger).to receive(:warn)

      expect { datum.send(:expire_circuit_data_cache) }.not_to raise_error
    end

    it "keys the cache per project" do
      expect(described_class.cache_key(project.id)).to eq("project_datum/#{project.id}")
    end
  end
end
