# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::Chromedriver do
  let(:chromedriver) { described_class }

  before { chromedriver.remove }

  describe '#update' do
    context 'when evaluating #correct_binary?' do
      it 'does not download when latest version and current version match' do
        allow(chromedriver).to receive(:latest_version).and_return(Gem::Version.new('72.0.0'))
        allow(chromedriver).to receive(:current_version).and_return(Gem::Version.new('72.0.0'))

        chromedriver.update

        expect(chromedriver.send(:exists?)).to be false
      end

      it 'does not download when offline, binary exists and is less than v70' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(chromedriver).to receive(:exists?).and_return(true)
        allow(chromedriver).to receive(:current_version).and_return(Gem::Version.new(69))

        chromedriver.update

        expect(File.exist?(chromedriver.driver_path)).to be false
      end

      it 'does not download when offline, binary exists and matches major browser version' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(chromedriver).to receive(:exists?).and_return(true)
        allow(chromedriver).to receive(:browser_version).and_return(Gem::Version.new('73.0.3683.68'))
        allow(chromedriver).to receive(:current_version).and_return(Gem::Version.new('73.0.3683.20'))

        chromedriver.update

        expect(File.exist?(chromedriver.driver_path)).to be false
      end

      it 'does not download when get raises exception, binary exists and matches major browser version' do
        client_error = instance_double(Net::HTTPNotFound, class: Net::HTTPNotFound, code: 404, message: '')

        allow(Webdrivers::Network).to receive(:get_response).and_return(client_error)
        allow(chromedriver).to receive(:exists?).and_return(true)
        allow(chromedriver).to receive(:browser_version).and_return(Gem::Version.new('73.0.3683.68'))
        allow(chromedriver).to receive(:current_version).and_return(Gem::Version.new('73.0.3683.20'))

        chromedriver.update

        expect(File.exist?(chromedriver.driver_path)).to be false
      end

      it 'raises ConnectionError when offline, and binary does not match major browser version' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(chromedriver).to receive(:exists?).and_return(true)
        allow(chromedriver).to receive(:browser_version).and_return(Gem::Version.new('73.0.3683.68'))
        allow(chromedriver).to receive(:current_version).and_return(Gem::Version.new('72.0.0.0'))

        msg = %r{Can not reach https://chromedriver.storage.googleapis.com}
        expect { chromedriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end

      it 'raises ConnectionError when offline, and no binary exists' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(chromedriver).to receive(:exists?).and_return(false)

        msg = %r{Can not reach https://chromedriver.storage.googleapis.com}
        expect { chromedriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end
    end

    context 'when correct binary is found' do
      before { allow(chromedriver).to receive(:correct_binary?).and_return(true) }

      it 'does not download' do
        chromedriver.update

        expect(chromedriver.current_version).to be_nil
      end

      it 'does not raise exception if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        chromedriver.update

        expect(chromedriver.current_version).to be_nil
      end
    end

    context 'when correct binary is not found' do
      before { allow(chromedriver).to receive(:correct_binary?).and_return(false) }

      it 'downloads binary' do
        chromedriver.update

        expect(chromedriver.current_version).not_to be_nil
      end

      it 'raises ConnectionError if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        msg = %r{Can not reach https://chromedriver.storage.googleapis.com/}
        expect { chromedriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end
    end

    it 'makes network calls if cached driver does not match the browser' do
      Webdrivers::System.cache_version('chromedriver', '71.0.3578.137')
      allow(chromedriver).to receive(:current_version).and_return(Gem::Version.new('71.0.3578.137'))
      allow(chromedriver).to receive(:browser_version).and_return(Gem::Version.new('73.0.3683.68'))
      allow(Webdrivers::Network).to receive(:get).and_return('73.0.3683.68')
      allow(Webdrivers::System).to receive(:download)

      chromedriver.update

      expect(Webdrivers::Network).to have_received(:get).twice
    end

    context 'when required version is 0' do
      it 'downloads the latest version' do
        allow(chromedriver).to receive(:latest_version).and_return(Gem::Version.new('72.0.3626.7'))
        chromedriver.required_version = 0
        chromedriver.update
        expect(chromedriver.current_version.version).to eq('72.0.3626.7')
      end
    end

    context 'when required version is nil' do
      it 'downloads the latest version' do
        allow(chromedriver).to receive(:latest_version).and_return(Gem::Version.new('72.0.3626.7'))
        chromedriver.required_version = nil
        chromedriver.update
        expect(chromedriver.current_version.version).to eq('72.0.3626.7')
      end
    end
  end

  describe '#current_version' do
    it 'returns nil if binary does not exist on the system' do
      allow(chromedriver).to receive(:driver_path).and_return('')

      expect(chromedriver.current_version).to be_nil
    end

    it 'returns a Gem::Version instance if binary is on the system' do
      allow(chromedriver).to receive(:exists?).and_return(true)
      allow(Webdrivers::System).to receive(:call)
        .with(chromedriver.driver_path, '--version')
        .and_return '71.0.3578.137'

      expect(chromedriver.current_version).to eq Gem::Version.new('71.0.3578.137')
    end
  end

  describe '#latest_version' do
    it 'returns 2.41 if the browser version is less than 70' do
      allow(chromedriver).to receive(:browser_version).and_return Gem::Version.new('69.0.0')

      expect(chromedriver.latest_version).to eq(Gem::Version.new('2.41'))
    end

    it 'returns the correct point release for a production version greater than 70' do
      allow(chromedriver).to receive(:browser_version).and_return Gem::Version.new('71.0.3578.9999')

      expect(chromedriver.latest_version).to eq Gem::Version.new('71.0.3578.137')
    end

    it 'raises VersionError for beta version' do
      allow(chromedriver).to receive(:browser_version).and_return Gem::Version.new('100.0.0')
      msg = 'Unable to find latest point release version for 100.0.0. '\
'You appear to be using a non-production version of Chrome. '\
'Please set `Webdrivers::Chromedriver.required_version = <desired driver version>` '\
'to a known chromedriver version: https://chromedriver.storage.googleapis.com/index.html'

      expect { chromedriver.latest_version }.to raise_exception(Webdrivers::VersionError, msg)
    end

    it 'raises VersionError for unknown version' do
      allow(chromedriver).to receive(:browser_version).and_return Gem::Version.new('72.0.9999.0000')
      msg = 'Unable to find latest point release version for 72.0.9999. '\
'Please set `Webdrivers::Chromedriver.required_version = <desired driver version>` '\
'to a known chromedriver version: https://chromedriver.storage.googleapis.com/index.html'

      expect { chromedriver.latest_version }.to raise_exception(Webdrivers::VersionError, msg)
    end

    it 'raises ConnectionError when offline' do
      allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

      msg = %r{^Can not reach https://chromedriver.storage.googleapis.com}
      expect { chromedriver.latest_version }.to raise_error(Webdrivers::ConnectionError, msg)
    end

    it 'creates cached file' do
      allow(Webdrivers::Network).to receive(:get).and_return('71.0.3578.137')

      chromedriver.latest_version
      expect(File.exist?("#{Webdrivers::System.install_dir}/chromedriver.version")).to eq true
    end

    it 'does not make network calls if cache is valid and driver exists' do
      allow(Webdrivers).to receive(:cache_time).and_return(3600)
      Webdrivers::System.cache_version('chromedriver', '71.0.3578.137')
      allow(chromedriver).to receive(:current_version).and_return Gem::Version.new('71.0.3578.137')
      allow(chromedriver).to receive(:browser_version).and_return Gem::Version.new('71.0.3578.137')
      allow(Webdrivers::System).to receive(:exists?).and_return(true)
      allow(Webdrivers::Network).to receive(:get)

      expect(chromedriver.latest_version).to eq Gem::Version.new('71.0.3578.137')

      expect(Webdrivers::Network).not_to have_received(:get)
    end

    it 'makes network calls if cache is expired' do
      Webdrivers::System.cache_version('chromedriver', '71.0.3578.137')
      allow(chromedriver).to receive(:browser_version).and_return Gem::Version.new('71.0.3578.137')
      allow(Webdrivers::Network).to receive(:get).and_return('73.0.3683.68')
      allow(Webdrivers::System).to receive(:valid_cache?).and_return(false)

      expect(chromedriver.latest_version).to eq Gem::Version.new('73.0.3683.68')

      expect(Webdrivers::Network).to have_received(:get)
      expect(Webdrivers::System).to have_received(:valid_cache?)
    end
  end

  describe '#required_version=' do
    after { chromedriver.required_version = nil }

    it 'returns the version specified as a Float' do
      chromedriver.required_version = 73.0

      expect(chromedriver.required_version).to eq Gem::Version.new('73.0')
    end

    it 'returns the version specified as a String' do
      chromedriver.required_version = '73.0'

      expect(chromedriver.required_version).to eq Gem::Version.new('73.0')
    end
  end

  describe '#remove' do
    it 'removes existing chromedriver' do
      chromedriver.update

      chromedriver.remove
      expect(chromedriver.current_version).to be_nil
    end

    it 'does not raise exception if no chromedriver found' do
      expect { chromedriver.remove }.not_to raise_error
    end
  end

  describe '#driver_path' do
    it 'returns full location of binary' do
      expected_bin = "chromedriver#{'.exe' if Selenium::WebDriver::Platform.windows?}"
      expected_path = File.absolute_path "#{File.join(ENV['HOME'])}/.webdrivers/#{expected_bin}"
      expect(chromedriver.driver_path).to eq(expected_path)
    end
  end

  describe '#browser_version' do
    it 'returns a Gem::Version object' do
      expect(chromedriver.browser_version).to be_an_instance_of(Gem::Version)
    end

    it 'returns currently installed Chrome version' do
      allow(Webdrivers::ChromeFinder).to receive(:version).and_return('72.0.0.0')
      expect(chromedriver.browser_version).to be Gem::Version.new('72.0.0.0')
    end
  end
end
