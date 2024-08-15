# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::Geckodriver do
  let(:geckodriver) { described_class }

  before do
    geckodriver.remove
    geckodriver.required_version = nil
  end

  describe '#update' do
    context 'when evaluating #correct_binary?' do
      it 'does not download when latest version and current version match' do
        allow(geckodriver).to receive(:latest_version).and_return(Gem::Version.new('0.3.0'))
        allow(geckodriver).to receive(:current_version).and_return(Gem::Version.new('0.3.0'))

        geckodriver.update

        expect(geckodriver.send(:exists?)).to be false
      end

      it 'does not download when offline, but binary exists' do
        allow(Webdrivers::System).to receive(:call).and_return('geckodriver 0.24.0 ( 2019-01-28)')
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(geckodriver).to receive(:exists?).and_return(true)

        geckodriver.update

        expect(File.exist?(geckodriver.driver_path)).to be false
      end

      it 'raises ConnectionError when offline, and no binary exists' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(geckodriver).to receive(:exists?).and_return(false)

        expect { geckodriver.update }.to raise_error(Webdrivers::ConnectionError)
      end
    end

    context 'when correct binary is found' do
      before { allow(geckodriver).to receive(:correct_binary?).and_return(true) }

      it 'does not download' do
        geckodriver.update

        expect(geckodriver.current_version).to be_nil
      end

      it 'does not raise exception if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        geckodriver.update

        expect(geckodriver.current_version).to be_nil
      end
    end

    context 'when correct binary is not found' do
      before { allow(geckodriver).to receive(:correct_binary?).and_return(false) }

      it 'downloads binary' do
        geckodriver.update

        expect(geckodriver.current_version).not_to be_nil
      end

      it 'raises ConnectionError if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        msg = %r{Can not reach https://github.com/mozilla/geckodriver/releases}
        expect { geckodriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end
    end

    it 'finds the required version from parsed downloads page' do
      base = 'https://github.com/mozilla/geckodriver/releases/download'
      url = %r{#{base}\/v0\.2\.0\/geckodriver-v0\.2\.0-}

      allow(Webdrivers::System).to receive(:download).with(url, geckodriver.driver_path)

      geckodriver.required_version = '0.2.0'
      geckodriver.update

      expect(Webdrivers::System).to have_received(:download).with(url, geckodriver.driver_path)
    end

    it 'does something when a wrong version is supplied' do
      geckodriver.required_version = '0.2.0'

      msg = /Net::HTTPServerException: 404 "Not Found"/
      expect { geckodriver.update }.to raise_error(StandardError, msg)
    end
  end

  describe '#current_version' do
    it 'returns nil if binary does not exist on the system' do
      allow(geckodriver).to receive(:driver_path).and_return('')

      expect(geckodriver.current_version).to be_nil
    end

    it 'returns a Gem::Version instance if binary is on the system' do
      allow(geckodriver).to receive(:exists?).and_return(true)

      return_value = "geckodriver 0.24.0 ( 2019-01-28)

The source code of this program is available from
testing/geckodriver in https://hg.mozilla.org/mozilla-central.

This program is subject to the terms of the Mozilla Public License 2.0.
You can obtain a copy of the license at https://mozilla.org/MPL/2.0/"

      allow(Webdrivers::System).to receive(:call).with(geckodriver.driver_path, '--version').and_return return_value

      expect(geckodriver.current_version).to eq Gem::Version.new('0.24.0')
    end
  end

  describe '#latest_version' do
    it 'finds the latest version directly' do
      url = 'https://github.com/mozilla/geckodriver/releases/tag/v0.24.0'
      allow(Webdrivers::Network).to receive(:get_url).and_return(url)

      geckodriver.update

      expect(geckodriver.latest_version).to eq Gem::Version.new('0.24.0')
    end

    it 'creates cached file' do
      allow(Webdrivers::Network).to receive(:get).and_return('0.24.0')

      geckodriver.latest_version
      expect(File.exist?("#{Webdrivers::System.install_dir}/geckodriver.version")).to eq true
    end

    it 'does not make network calls if cache is valid and driver exists' do
      allow(Webdrivers).to receive(:cache_time).and_return(3600)
      Webdrivers::System.cache_version('geckodriver', '0.23.0')
      allow(Webdrivers::System).to receive(:exists?).and_return(true)
      allow(Webdrivers::Network).to receive(:get)

      expect(geckodriver.latest_version).to eq Gem::Version.new('0.23.0')

      expect(Webdrivers::Network).not_to have_received(:get)
    end

    it 'makes a network call if cache is expired' do
      Webdrivers::System.cache_version('geckodriver', '0.23.0')
      url = 'https://github.com/mozilla/geckodriver/releases/tag/v0.24.0'
      allow(Webdrivers::Network).to receive(:get_url).and_return(url)
      allow(Webdrivers::System).to receive(:valid_cache?)

      expect(geckodriver.latest_version).to eq Gem::Version.new('0.24.0')

      expect(Webdrivers::Network).to have_received(:get_url)
      expect(Webdrivers::System).to have_received(:valid_cache?)
    end
  end

  describe '#required_version=' do
    it 'returns the version specified as a Float' do
      geckodriver.required_version = 0.12

      expect(geckodriver.required_version).to eq Gem::Version.new('0.12')
    end

    it 'returns the version specified as a String' do
      geckodriver.required_version = '0.12.1'

      expect(geckodriver.required_version).to eq Gem::Version.new('0.12.1')
    end
  end

  describe '#remove' do
    it 'removes existing geckodriver' do
      geckodriver.update

      geckodriver.remove
      expect(geckodriver.current_version).to be_nil
    end

    it 'does not raise exception if no geckodriver found' do
      expect { geckodriver.remove }.not_to raise_error
    end
  end

  describe '#install_dir' do
    it 'uses ~/.webdrivers as default value' do
      expect(Webdrivers::System.install_dir).to include('.webdriver')
    end

    it 'uses provided value' do
      install_dir = File.expand_path(File.join(ENV['HOME'], '.webdrivers2'))
      Webdrivers.install_dir = install_dir

      expect(Webdrivers::System.install_dir).to eq install_dir
    ensure
      Webdrivers.install_dir = nil
    end
  end

  describe '#driver_path' do
    it 'returns full location of binary' do
      expected_bin = "geckodriver#{'.exe' if Selenium::WebDriver::Platform.windows?}"
      expected_path = File.absolute_path "#{File.join(ENV['HOME'])}/.webdrivers/#{expected_bin}"
      expect(geckodriver.driver_path).to eq(expected_path)
    end
  end
end
