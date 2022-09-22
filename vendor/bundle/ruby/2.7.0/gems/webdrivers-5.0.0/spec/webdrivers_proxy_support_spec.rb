# frozen_string_literal: true

require 'spec_helper'

class FakeDriver < Webdrivers::Common
  def self.http_object
    Webdrivers::Network.http
  end
end

describe Webdrivers do
  let(:http_object) { FakeDriver.http_object }

  before do
    described_class.proxy_addr = nil
    described_class.proxy_port = nil
    described_class.proxy_user = nil
    described_class.proxy_pass = nil
  end

  it 'allows the proxy values to be set via configuration' do
    described_class.configure do |config|
      config.proxy_addr = 'proxy_addr'
      config.proxy_port = '8888'
      config.proxy_user = 'proxy_user'
      config.proxy_pass = 'proxy_pass'
    end

    expect(described_class.proxy_addr).to eql 'proxy_addr'
    expect(described_class.proxy_port).to eql '8888'
    expect(described_class.proxy_user).to eql 'proxy_user'
    expect(described_class.proxy_pass).to eql 'proxy_pass'
  end

  it 'uses the Proxy when the proxy_addr is set' do
    described_class.configure do |config|
      config.proxy_addr = 'proxy_addr'
      config.proxy_port = '8080'
    end

    expect(http_object.instance_variable_get('@is_proxy_class')).to be true
  end

  it 'does not use the Proxy when proxy is not configured' do
    expect(http_object.instance_variable_get('@is_proxy_class')).to be false
  end

  it 'raises an exception when net_http_ssl_fix is called.' do
    err = 'Webdrivers.net_http_ssl_fix is no longer available.' \
      ' Please see https://github.com/titusfortner/webdrivers#ssl_connect-errors.'
    expect { described_class.net_http_ssl_fix }.to raise_error(RuntimeError, err)
  end
end
