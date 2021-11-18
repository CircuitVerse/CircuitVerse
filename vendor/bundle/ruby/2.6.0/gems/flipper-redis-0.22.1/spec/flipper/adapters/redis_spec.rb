require 'helper'
require 'flipper/adapters/redis'
require 'flipper/spec/shared_adapter_specs'

RSpec.describe Flipper::Adapters::Redis do
  let(:client) do
    options = {}

    options[:url] = ENV['REDIS_URL'] if ENV['REDIS_URL']

    Redis.new(options)
  end

  subject { described_class.new(client) }

  before do
    begin
      client.flushdb
    rescue Redis::CannotConnectError
      ENV['CI'] ? raise : skip('Redis not available')
    end
  end

  it_should_behave_like 'a flipper adapter'

  it 'configures itself on load' do
    Flipper.configuration = nil
    Flipper.instance = nil

    load 'flipper/adapters/redis.rb'

    expect(Flipper.adapter.adapter).to be_a(Flipper::Adapters::Redis)
  end
end
