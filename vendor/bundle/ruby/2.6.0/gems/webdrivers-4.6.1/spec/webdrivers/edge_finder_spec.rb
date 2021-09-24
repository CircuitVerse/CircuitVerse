# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::EdgeFinder do
  let(:edge_finder) { described_class }

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    if Selenium::WebDriver::VERSION[0].to_i < 4
      skip "The current selenium-webdriver doesn't include Chromium based Edge support"
    end
  end

  context 'when the user relies on the gem to figure out the location of Edge' do
    it 'determines the location correctly based on the current OS' do
      expect { edge_finder.location }.not_to raise_error
    end
  end

  context 'when the user provides a path to the Edge binary' do
    it 'uses Selenium::WebDriver::Edge.path when it is defined' do
      Selenium::WebDriver::Edge.path = edge_finder.location
      locations = %i[win_location mac_location linux_location]
      allow(edge_finder).to receive_messages(locations)

      expect(edge_finder.version).not_to be_nil
      locations.each { |loc| expect(edge_finder).not_to have_received(loc) }
    end

    it "uses ENV['WD_EDGE_PATH'] when it is defined" do
      allow(ENV).to receive(:[]).with('WD_EDGE_PATH').and_return(edge_finder.location)
      locations = %i[win_location mac_location linux_location]
      allow(edge_finder).to receive_messages(locations)

      expect(edge_finder.version).not_to be_nil
      locations.each { |loc| expect(edge_finder).not_to have_received(loc) }
    end

    it 'uses Selenium::WebDriver::Edge.path over WD_EDGE_PATH' do
      Selenium::WebDriver::Edge.path = edge_finder.location
      allow(ENV).to receive(:[]).with('WD_EDGE_PATH').and_return('my_wd_chrome_path')
      expect(edge_finder.version).not_to be_nil
      expect(ENV).not_to have_received(:[]).with('WD_EDGE_PATH')
    end
  end

  context 'when Edge is not installed' do
    it 'raises BrowserNotFound' do
      locations = %i[win_location mac_location linux_location]
      allow(edge_finder).to receive_messages(locations)
      allow(edge_finder).to receive(:user_defined_location).and_return(nil)

      expect { edge_finder.version }.to raise_error(Webdrivers::BrowserNotFound)
    end
  end
end
