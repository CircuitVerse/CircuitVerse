# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::Edgedriver do
  let(:edgedriver) { described_class }

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    if Selenium::WebDriver::VERSION[0].to_i < 4
      skip "The current selenium-webdriver doesn't include Chromium based Edge support"
    end
  end

  before { edgedriver.remove }

  describe '#update' do
    context 'when evaluating #correct_binary?' do
      it 'does not download when latest version and current version match' do
        allow(edgedriver).to receive(:latest_version).and_return(Gem::Version.new('72.0.0'))
        allow(edgedriver).to receive(:current_version).and_return(Gem::Version.new('72.0.0'))

        edgedriver.update

        expect(edgedriver.send(:exists?)).to be false
      end

      it 'does not download when offline, binary exists and is less than v70' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(edgedriver).to receive(:exists?).and_return(true)
        allow(edgedriver).to receive(:current_version).and_return(Gem::Version.new(69))

        edgedriver.update

        expect(File.exist?(edgedriver.driver_path)).to be false
      end

      it 'does not download when offline, binary exists and matches major browser version' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(edgedriver).to receive(:exists?).and_return(true)
        allow(edgedriver).to receive(:browser_version).and_return(Gem::Version.new('73.0.3683.68'))
        allow(edgedriver).to receive(:current_version).and_return(Gem::Version.new('73.0.3683.20'))

        edgedriver.update

        expect(File.exist?(edgedriver.driver_path)).to be false
      end

      it 'does not download when get raises exception, binary exists and matches major browser version' do
        client_error = instance_double(Net::HTTPNotFound, class: Net::HTTPNotFound, code: 404, message: '')

        allow(Webdrivers::Network).to receive(:get_response).and_return(client_error)
        allow(edgedriver).to receive(:exists?).and_return(true)
        allow(edgedriver).to receive(:browser_version).and_return(Gem::Version.new('73.0.3683.68'))
        allow(edgedriver).to receive(:current_version).and_return(Gem::Version.new('73.0.3683.20'))

        edgedriver.update

        expect(File.exist?(edgedriver.driver_path)).to be false
      end

      it 'raises ConnectionError when offline, and binary does not match major browser version' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(edgedriver).to receive(:exists?).and_return(true)
        allow(edgedriver).to receive(:browser_version).and_return(Gem::Version.new('73.0.3683.68'))
        allow(edgedriver).to receive(:current_version).and_return(Gem::Version.new('72.0.0.0'))

        msg = %r{Can not reach https://msedgedriver.azureedge.net/}
        expect { edgedriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end

      it 'raises ConnectionError when offline, and no binary exists' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(edgedriver).to receive(:exists?).and_return(false)

        msg = %r{Can not reach https://msedgedriver.azureedge.net/}
        expect { edgedriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end
    end

    context 'when correct binary is found' do
      before { allow(edgedriver).to receive(:correct_binary?).and_return(true) }

      it 'does not download' do
        edgedriver.update

        expect(edgedriver.current_version).to be_nil
      end

      it 'does not raise exception if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        edgedriver.update

        expect(edgedriver.current_version).to be_nil
      end
    end

    context 'when correct binary is not found' do
      before { allow(edgedriver).to receive(:correct_binary?).and_return(false) }

      it 'downloads binary' do
        edgedriver.update

        expect(edgedriver.current_version).not_to be_nil
      end

      it 'raises ConnectionError if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        msg = %r{Can not reach https://msedgedriver.azureedge.net/}
        expect { edgedriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end
    end

    it 'makes network calls if cached driver does not match the browser' do
      Webdrivers::System.cache_version('msedgedriver', '71.0.3578.137')
      allow(edgedriver).to receive(:current_version).and_return Gem::Version.new('71.0.3578.137')
      allow(edgedriver).to receive(:browser_version).and_return Gem::Version.new('73.0.3683.68')
      allow(Webdrivers::Network).to receive(:get).and_return('73.0.3683.68'.encode('UTF-16'))
      allow(Webdrivers::System).to receive(:download)

      edgedriver.update

      expect(Webdrivers::Network).to have_received(:get).twice
    end

    context 'when required version is 0' do
      it 'downloads the latest version' do
        allow(edgedriver).to receive(:latest_version).and_return(Gem::Version.new('77.0.207.0'))
        edgedriver.required_version = 0
        edgedriver.update
        expect(edgedriver.current_version.version).to eq('77.0.207.0')
      end
    end

    context 'when required version is nil' do
      it 'downloads the latest version' do
        allow(edgedriver).to receive(:latest_version).and_return(Gem::Version.new('77.0.207.0'))
        edgedriver.required_version = nil
        edgedriver.update
        expect(edgedriver.current_version.version).to eq('77.0.207.0')
      end
    end
  end

  describe '#current_version' do
    it 'returns nil if binary does not exist on the system' do
      allow(edgedriver).to receive(:driver_path).and_return('')

      expect(edgedriver.current_version).to be_nil
    end

    it 'returns a Gem::Version instance if binary is on the system' do
      allow(edgedriver).to receive(:exists?).and_return(true)
      allow(Webdrivers::System).to receive(:call)
        .with(edgedriver.driver_path, '--version')
        .and_return '71.0.3578.137'

      expect(edgedriver.current_version).to eq Gem::Version.new('71.0.3578.137')
    end
  end

  describe '#latest_version' do
    it 'returns the correct point release for a production version' do
      allow(edgedriver).to receive(:browser_version).and_return Gem::Version.new('77.0.207.0')

      expect(edgedriver.latest_version).to be_between(Gem::Version.new('77.0.207.0'), Gem::Version.new('78'))
    end

    it 'raises VersionError for beta version' do
      allow(edgedriver).to receive(:browser_version).and_return Gem::Version.new('100.0.0')
      msg = 'Unable to find latest point release version for 100.0.0. '\
'You appear to be using a non-production version of Edge. '\
'Please set `Webdrivers::Edgedriver.required_version = <desired driver version>` '\
'to a known edgedriver version: Can not reach https://msedgedriver.azureedge.net/'

      expect { edgedriver.latest_version }.to raise_exception(Webdrivers::VersionError, msg)
    end

    it 'raises VersionError for unknown version' do
      skip "MS doesn't yet support point release latest versioning."
      allow(edgedriver).to receive(:browser_version).and_return('77.0.9999.0000')
      msg = 'Unable to find latest point release version for 77.0.9999. '\
'Please set `Webdrivers::Edgedriver.required_version = <desired driver version>` '\
'to a known edgedriver version: Can not reach https://msedgedriver.azureedge.net/'

      expect { edgedriver.latest_version }.to raise_exception(Webdrivers::VersionError, msg)
    end

    it 'raises ConnectionError when offline' do
      allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

      msg = %r{^Can not reach https://msedgedriver.azureedge.net}
      expect { edgedriver.latest_version }.to raise_error(Webdrivers::ConnectionError, msg)
    end

    it 'creates cached file' do
      allow(edgedriver).to receive(:browser_version).and_return Gem::Version.new('77.0.207.0')
      allow(Webdrivers::Network).to receive(:get).and_return('77.0.207.0'.encode('UTF-16'))

      edgedriver.latest_version
      expect(File.exist?("#{Webdrivers::System.install_dir}/msedgedriver.version")).to eq true
    end

    it 'does not make network calls if cache is valid and driver exists' do
      allow(Webdrivers).to receive(:cache_time).and_return(3600)
      Webdrivers::System.cache_version('msedgedriver', '82.0.445.0')
      allow(edgedriver).to receive(:current_version).and_return Gem::Version.new('82.0.445.0')
      allow(edgedriver).to receive(:browser_version).and_return Gem::Version.new('82.0.445.0')
      allow(Webdrivers::System).to receive(:exists?).and_return(true)
      allow(Webdrivers::Network).to receive(:get)

      expect(edgedriver.latest_version).to eq Gem::Version.new('82.0.445.0')

      expect(Webdrivers::Network).not_to have_received(:get)
    end

    it 'makes network calls if cache is expired' do
      Webdrivers::System.cache_version('msedgedriver', '71.0.3578.137')
      allow(Webdrivers::Network).to receive(:get).and_return('77.0.207.0'.encode('UTF-16'))
      allow(Webdrivers::System).to receive(:valid_cache?).and_return(false)
      allow(edgedriver).to receive(:browser_version).and_return Gem::Version.new('77.0.207.0')

      expect(edgedriver.latest_version).to eq Gem::Version.new('77.0.207.0')

      expect(Webdrivers::Network).to have_received(:get)
      expect(Webdrivers::System).to have_received(:valid_cache?)
    end
  end

  describe '#required_version=' do
    after { edgedriver.required_version = nil }

    it 'returns the version specified as a Float' do
      edgedriver.required_version = 73.0

      expect(edgedriver.required_version).to eq Gem::Version.new('73.0')
    end

    it 'returns the version specified as a String' do
      edgedriver.required_version = '73.0'

      expect(edgedriver.required_version).to eq Gem::Version.new('73.0')
    end
  end

  describe '#remove' do
    it 'removes existing edgedriver' do
      edgedriver.update

      edgedriver.remove
      expect(edgedriver.current_version).to be_nil
    end

    it 'does not raise exception if no edgedriver found' do
      expect { edgedriver.remove }.not_to raise_error
    end
  end

  describe '#driver_path' do
    it 'returns full location of binary' do
      expected_bin = "msedgedriver#{'.exe' if Selenium::WebDriver::Platform.windows?}"
      expected_path = File.absolute_path "#{File.join(ENV['HOME'])}/.webdrivers/#{expected_bin}"
      expect(edgedriver.driver_path).to eq(expected_path)
    end
  end

  describe '#browser_version' do
    it 'returns a Gem::Version object' do
      expect(edgedriver.browser_version).to be_an_instance_of(Gem::Version)
    end

    it 'returns currently installed Edge version' do
      allow(Webdrivers::EdgeFinder).to receive(:version).and_return('72.0.0.0')
      expect(edgedriver.browser_version).to be Gem::Version.new('72.0.0.0')
    end
  end
end
