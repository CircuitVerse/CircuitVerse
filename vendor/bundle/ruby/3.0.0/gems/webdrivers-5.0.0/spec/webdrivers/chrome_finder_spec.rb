# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::ChromeFinder do
  let(:chrome_finder) { described_class }

  context 'when the user relies on the gem to figure out the location of Chrome' do
    it 'determines the location correctly based on the current OS' do
      expect { chrome_finder.location }.not_to raise_error
    end
  end

  context 'when the user provides a path to the Chrome binary' do
    it 'uses Selenium::WebDriver::Chrome.path when it is defined' do
      Selenium::WebDriver::Chrome.path = chrome_finder.location
      locations = %i[win_location mac_location linux_location]
      allow(chrome_finder).to receive_messages(locations)

      expect(chrome_finder.version).not_to be_nil
      locations.each { |loc| expect(chrome_finder).not_to have_received(loc) }
    end
  end

  it "uses ENV['WD_CHROME_PATH'] when it is defined" do
    allow(ENV).to receive(:[]).with('WD_CHROME_PATH').and_return(chrome_finder.location)
    locations = %i[win_location mac_location linux_location]
    allow(chrome_finder).to receive_messages(locations)

    expect(chrome_finder.version).not_to be_nil
    locations.each { |loc| expect(chrome_finder).not_to have_received(loc) }
  end

  it 'uses Selenium::WebDriver::Chrome.path over WD_CHROME_PATH' do
    Selenium::WebDriver::Chrome.path = chrome_finder.location
    allow(ENV).to receive(:[]).with('WD_CHROME_PATH').and_return('my_wd_chrome_path')
    expect(chrome_finder.version).not_to be_nil
    expect(ENV).not_to have_received(:[]).with('WD_CHROME_PATH')
  end

  context 'when Chrome is not installed' do
    it 'raises BrowserNotFound' do
      locations = %i[win_location mac_location linux_location]
      allow(chrome_finder).to receive_messages(locations)
      allow(chrome_finder).to receive(:user_defined_location).and_return(nil)

      expect { chrome_finder.version }.to raise_error(Webdrivers::BrowserNotFound)
    end
  end

  context 'when running in WSL' do
    before do
      skip "The current platform cannot be WSL, as it's not Linux" unless Selenium::WebDriver::Platform.linux?

      allow(Webdrivers::System).to receive(:wsl_v1?).and_return(true)
      allow(Webdrivers::System).to receive(:to_wsl_path).and_return('')
      allow(Webdrivers::System).to receive(:to_win32_path).and_return('')
    end

    it 'checks Windows locations for Chrome' do
      drive = 'c'
      user = 'WinUser'
      file = 'chrome.exe'
      path = [
        '/home/wsl-user/.local/bin',
        '/usr/local/bin',
        '/usr/local/games',
        '/usr/bin',
        "/#{drive}/Users/#{user}/AppData/Local/Microsoft/WindowsApps",
        '/snap/bin'
      ].join ':'

      allow(chrome_finder).to receive(:user_defined_location).and_return(nil)
      allow(ENV).to receive(:[]).with('WD_CHROME_PATH').and_return(nil)
      allow(ENV).to receive(:[]).with('PATH').and_return(path)
      allow(File).to receive(:exist?).and_return(false)

      locations = [
        "#{drive}:\\Users\\#{user}\\AppData\\Local\\Google\\Chrome\\Application\\#{file}",
        "#{drive}:\\Program Files (x86)\\Chromium\\Application\\#{file}",
        "#{drive}:\\Program Files\\Google\\Chrome\\Application\\#{file}"
      ]

      # CIs don't support WSL yet, so our mocks lead to the error path for simplicity
      expect { chrome_finder.location }.to raise_error(Webdrivers::BrowserNotFound)

      locations.each do |dir|
        expect(Webdrivers::System).to have_received(:to_wsl_path).with(dir)
      end
    end

    it 'uses win_version to get the Chrome version using win32 path' do
      allow(chrome_finder).to receive(:win_version).and_return('')
      allow(File).to receive(:exist?).and_return(true)

      # CIs don't support WSL yet, so our mocks lead to the error path for simplicity
      expect { chrome_finder.version }.to raise_error(Webdrivers::VersionError)

      expect(Webdrivers::System).to have_received(:to_win32_path)
      expect(chrome_finder).to have_received(:win_version)
    end
  end
end
