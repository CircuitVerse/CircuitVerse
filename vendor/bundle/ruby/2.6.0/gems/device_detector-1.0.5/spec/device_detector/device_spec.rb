# frozen_string_literal: true

require_relative '../spec_helper'

describe DeviceDetector::Device do
  subject { DeviceDetector::Device.new(user_agent) }

  alias_method :device, :subject

  describe '#name' do
    describe 'when models are nested' do
      let(:user_agent) { 'Mozilla/5.0 (iPhone; CPU iPhone OS 8_1_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B466 [FBDV/iPhone7,2]' }

      it 'finds an Apple iPhone 6' do
        value(device.name).must_equal 'iPhone 6'
      end
    end

    describe 'when models are NOT nested' do
      let(:user_agent) { 'AIRNESS-AIR99/REV 2.2.1/Teleca Q03B1' }

      it 'finds an Airness AIR99' do
        value(device.name).must_equal 'AIR99'
      end
    end

    describe 'when it cannot find a device name' do
      let(:user_agent) { 'UNKNOWN MODEL NAME' }

      it 'returns nil' do
        value(device.name).must_be_nil
      end
    end
  end

  describe '#type' do
    describe 'when models are nested' do
      let(:user_agent) { 'Mozilla/5.0 (iPhone; CPU iPhone OS 8_1_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B466 [FBDV/iPhone7,2]' }

      it 'finds device of Apple iPhone 6' do
        value(device.type).must_equal 'smartphone'
      end
    end

    describe 'when models are NOT nested' do
      let(:user_agent) { 'AIRNESS-AIR99/REV 2.2.1/Teleca Q03B1' }

      it 'finds the device of Airness AIR99' do
        value(device.type).must_equal 'feature phone'
      end
    end

    describe 'when it cannot find a device type' do
      let(:user_agent) { 'UNKNOWN MODEL TYPE' }

      it 'returns nil' do
        value(device.type).must_be_nil
      end
    end

    describe 'device not specified in nested block' do
      let(:user_agent) { 'Mozilla/5.0 (Linux; Android 4.4.2; es-us; SAMSUNG SM-G900F Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko)' }

      it 'falls back to top-level device' do
        value(device.type).must_equal 'smartphone'
      end
    end
  end

  describe 'concrete device types' do
    describe 'mobiles' do
      let(:user_agent) { 'Mozilla/5.0 (Linux; Android 4.4.2; es-us; SAMSUNG SM-G900F Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko)' }

      it 'identifies the device' do
        value(device.name).must_equal 'GALAXY S5'
        value(device.type).must_equal 'smartphone'
        value(device.brand).must_equal 'Samsung'
      end
    end

    describe 'cameras' do
      let(:user_agent) { 'Mozilla/5.0 (Linux; U; Android 4.0; xx-xx; EK-GC100 Build/IMM76D) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30' }

      it 'identifies the device' do
        value(device.name).must_equal 'GALAXY Camera'
        value(device.type).must_equal 'camera'
        value(device.brand).must_equal 'Samsung'
      end
    end

    describe 'car browsers' do
      let(:user_agent) { 'Mozilla/5.0 (X11; Linux) AppleWebKit/534.34 (KHTML, like Gecko) QtCarBrowser Safari/534.34' }

      it 'identifies the device' do
        value(device.name).must_equal 'Model S'
        value(device.type).must_equal 'car browser'
        value(device.brand).must_equal 'Tesla'
      end
    end

    describe '(gaming) consoles' do
      let(:user_agent) { 'Opera/9.30 (Nintendo Wii; U; ; 2047-7;en)' }

      it 'identifies the device' do
        value(device.name).must_equal 'Wii'
        value(device.type).must_equal 'console'
        value(device.brand).must_be_nil
      end
    end

    describe 'portable media players' do
      let(:user_agent) { 'Mozilla/5.0 (iPod touch; CPU iPhone OS 7_0_6 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B651 Safari/9537.53' }

      it 'identifies the device' do
        value(device.name).must_equal 'iPod Touch'
        value(device.type).must_equal 'portable media player'
        value(device.brand).must_equal 'Apple'
      end
    end

    describe 'televisions' do
      let(:user_agent) { 'Mozilla/5.0 (Unknown; Linux armv7l) AppleWebKit/537.1+ (KHTML, like Gecko) Safari/537.1+ HbbTV/1.1.1 ( ;LGE ;NetCast 4.0 ;03.10.81 ;1.0M ;)' }

      it 'identifies the device' do
        value(device.name).must_equal 'NetCast 4.0'
        value(device.type).must_equal 'tv'
        value(device.brand).must_equal 'LG'
      end
    end
  end
end
