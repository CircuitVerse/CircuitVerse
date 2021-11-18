# frozen_string_literal: true

require_relative 'spec_helper'

describe DeviceDetector do
  subject { DeviceDetector.new(user_agent) }

  alias_method :client, :subject

  describe 'known user agent' do
    describe 'desktop chrome browser' do
      let(:user_agent) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.69' }

      describe '#name' do
        it 'returns the name' do
          value(client.name).must_equal 'Chrome'
        end
      end

      describe '#full_version' do
        it 'returns the full version' do
          value(client.full_version).must_equal '30.0.1599.69'
        end
      end

      describe '#os_family' do
        it 'returns the operating system name' do
          value(client.os_family).must_equal 'Mac'
        end
      end

      describe '#os_name' do
        it 'returns the operating system name' do
          value(client.os_name).must_equal 'Mac'
        end
      end

      describe '#os_full_version' do
        it 'returns the operating system full version' do
          value(client.os_full_version).must_equal '10.8.5'
        end
      end

      describe '#known?' do
        it 'returns true' do
          value(client.known?).must_equal true
        end
      end

      describe '#bot?' do
        it 'returns false' do
          value(client.bot?).must_equal false
        end
      end

      describe '#bot_name' do
        it 'returns nil' do
          value(client.bot_name).must_be_nil
        end
      end
    end

    describe 'ubuntu linux' do
      let(:user_agent) do
        'Mozilla/5.0 (X11; Ubuntu; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36'
      end

      describe '#os_family' do
        it 'returns the operating system name' do
          value(client.os_family).must_equal 'GNU/Linux'
        end
      end

      describe '#os_name' do
        it 'returns the operating system name' do
          value(client.os_name).must_equal 'Ubuntu'
        end
      end
    end

    describe 'firefox mobile phone' do
      let(:user_agent) { 'Mozilla/5.0 (Android 7.0; Mobile; rv:53.0) Gecko/53.0 Firefox/53.0' }

      it 'detects smartphone' do
        value(client.device_type).must_equal 'smartphone'
      end
    end

    describe 'firefox mobile tablet' do
      let(:user_agent) { 'Mozilla/5.0 (Android 6.0.1; Tablet; rv:47.0) Gecko/47.0 Firefox/47.0' }

      it 'detects tablet' do
        value(client.device_type).must_equal 'tablet'
      end
    end
  end

  describe 'unknown user agent' do
    let(:user_agent) { 'garbage123' }

    describe '#name' do
      it 'returns nil' do
        value(client.name).must_be_nil
      end
    end

    describe '#full_version' do
      it 'returns nil' do
        value(client.full_version).must_be_nil
      end
    end

    describe '#os_name' do
      it 'returns nil' do
        value(client.os_name).must_be_nil
      end
    end

    describe '#os_full_version' do
      it 'returns nil' do
        value(client.os_full_version).must_be_nil
      end
    end

    describe '#known?' do
      it 'returns false' do
        value(client.known?).must_equal false
      end
    end

    describe '#bot?' do
      it 'returns false' do
        value(client.bot?).must_equal false
      end
    end

    describe '#bot_name' do
      it 'returns nil' do
        value(client.bot_name).must_be_nil
      end
    end
  end

  describe 'bot' do
    let(:user_agent) { 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)' }

    describe '#name' do
      it 'returns nil' do
        value(client.name).must_be_nil
      end
    end

    describe '#full_version' do
      it 'returns nil' do
        value(client.full_version).must_be_nil
      end
    end

    describe '#os_name' do
      it 'returns nil' do
        value(client.os_name).must_be_nil
      end
    end

    describe '#os_full_version' do
      it 'returns nil' do
        value(client.os_full_version).must_be_nil
      end
    end

    describe '#known?' do
      it 'returns false' do
        value(client.known?).must_equal false
      end
    end

    describe '#bot?' do
      it 'returns true' do
        value(client.bot?).must_equal true
      end
    end

    describe '#bot_name' do
      it 'returns the name of the bot' do
        value(client.bot_name).must_equal 'Googlebot'
      end
    end
  end
end
