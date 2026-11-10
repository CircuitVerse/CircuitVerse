# frozen_string_literal: true

require "sidekiq"
require "sidekiq/config"

RSpec.describe "Sidekiq Redis configuration" do
  let(:client_config) { Sidekiq::Config.new }
  let(:server_config) { Sidekiq::Config.new }
  let(:timeout_value) { nil }
  let(:beta) { nil }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:key?).and_call_original
    allow(ENV).to receive(:[]).with("BETA").and_return(beta)
    allow(ENV).to receive(:[]).with("SIDEKIQ_REDIS_NETWORK_TIMEOUT").and_return(timeout_value)
    allow(ENV).to receive(:key?).with("SIDEKIQ_REDIS_NETWORK_TIMEOUT").and_return(!timeout_value.nil?)
    allow(ENV).to receive(:[]).with("REDIS_PROVIDER").and_return(nil)
    allow(ENV).to receive(:[]).with("REDIS_URL").and_return("redis://redis.example.test:6380/8")
    allow(Sidekiq).to receive(:configure_client).and_yield(client_config)
    allow(Sidekiq).to receive(:configure_server).and_yield(server_config)
  end

  def load_initializer
    load File.expand_path("../../config/initializers/sidekiq.rb", __dir__)
  end

  def redis_config_for(config)
    config.local_redis_pool.with(&:config)
  end

  it "preserves the upstream timeout and Redis URL while selecting the production database" do
    load_initializer

    [client_config, server_config].each do |config|
      redis = redis_config_for(config)
      expect(redis.read_timeout).to eq(3)
      expect(redis.db).to eq(0)
      expect(redis.host).to eq("redis.example.test")
      expect(redis.port).to eq(6380)
    end
  end

  context "with a fractional network timeout" do
    let(:timeout_value) { "7.5" }

    it "applies the timeout to both web and worker Redis connections" do
      load_initializer

      [client_config, server_config].each do |config|
        redis = redis_config_for(config)
        expect(redis.connect_timeout).to eq(7.5)
        expect(redis.read_timeout).to eq(7.5)
        expect(redis.write_timeout).to eq(7.5)
      end
    end
  end

  context "on beta" do
    let(:beta) { "true" }
    let(:timeout_value) { "5" }

    it "retains the separate beta database with a custom timeout" do
      load_initializer

      [client_config, server_config].each do |config|
        redis = redis_config_for(config)
        expect(redis.db).to eq(1)
        expect(redis.read_timeout).to eq(5)
      end
    end
  end

  ["", "not-a-number", "0", "-1", "NaN", "Infinity", "1e309"].each do |invalid_timeout|
    context "when the timeout is #{invalid_timeout.inspect}" do
      let(:timeout_value) { invalid_timeout }

      it "rejects the value before configuring either process" do
        expect { load_initializer }.to raise_error(ArgumentError, /SIDEKIQ_REDIS_NETWORK_TIMEOUT/)
        expect(Sidekiq).not_to have_received(:configure_client)
        expect(Sidekiq).not_to have_received(:configure_server)
      end
    end
  end
end
