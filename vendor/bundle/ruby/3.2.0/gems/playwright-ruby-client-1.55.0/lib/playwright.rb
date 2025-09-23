# frozen_string_literal: true

# namespace declaration
module Playwright; end

# concurrent-ruby
require 'concurrent'

# modules & constants
require 'playwright/errors'
require 'playwright/events'
require 'playwright/event_emitter'
require 'playwright/event_emitter_proxy'
require 'playwright/javascript'
require 'playwright/utils'

require 'playwright/api_implementation'
require 'playwright/channel'
require 'playwright/channel_owner'
require 'playwright/http_headers'
require 'playwright/input_files'
require 'playwright/connection'
require 'playwright/har_router'
require 'playwright/raw_headers'
require 'playwright/route_handler'
require 'playwright/select_option_values'
require 'playwright/timeout_settings'
require 'playwright/transport'
require 'playwright/url_matcher'
require 'playwright/version'
require 'playwright/video'
require 'playwright/waiter'

require 'playwright/playwright_api'
# load generated files
Dir[File.join(__dir__, 'playwright_api', '*.rb')].each { |f| require f }

module Playwright
  class Execution
    def initialize(connection, playwright, browser = nil)
      @connection = connection
      @playwright = playwright
      @browser = browser
    end

    def stop
      @browser&.close
      @connection.stop
    end

    attr_reader :playwright, :browser
  end

  class AndroidExecution
    def initialize(connection, playwright, device = nil)
      @connection = connection
      @playwright = playwright
      @device = device
    end

    def stop
      @device&.close
      @connection.stop
    end

    attr_reader :playwright, :device
  end


  # Recommended to call this method with block.
  #
  # Playwright.create(...) do |playwright|
  #   browser = playwright.chromium.launch
  #   ...
  # end
  #
  # When we use this method without block, an instance of Playwright::Execution is returned
  # and we *must* call execution.stop on the end.
  # The instance of playwright is available by calling execution.playwright
  module_function def create(playwright_cli_executable_path:, &block)
    transport = Transport.new(playwright_cli_executable_path: playwright_cli_executable_path)
    connection = Connection.new(transport)
    connection.async_run

    execution =
      begin
        playwright = connection.initialize_playwright
        Execution.new(connection, PlaywrightApi.wrap(playwright))
      rescue
        connection.stop
        raise
      end

    if block
      begin
        block.call(execution.playwright)
      ensure
        execution.stop
      end
    else
      execution
    end
  end

  # @Deprecated. Playwright >= 1.54 does not support this method.
  module_function def connect_to_playwright_server(ws_endpoint, &block)
    require 'playwright/web_socket_client'
    require 'playwright/web_socket_transport'

    transport = WebSocketTransport.new(ws_endpoint: ws_endpoint)
    connection = Connection.new(transport)
    connection.async_run

    execution =
      begin
        playwright = connection.initialize_playwright
        Execution.new(connection, PlaywrightApi.wrap(playwright))
      rescue
        connection.stop
        raise
      end

    if block
      begin
        block.call(execution.playwright)
      ensure
        execution.stop
      end
    else
      execution
    end
  end

  # Connects to Playwright server, launched by `npx playwright launch-server --browser chromium` or `npx playwright run-server`
  #
  # Playwright.connect_to_browser_server('ws://....') do |browser|
  #   page = browser.new_page
  #   ...
  # end
  #
  # @experimental
  module_function def connect_to_browser_server(ws_endpoint, browser_type: 'chromium', &block)
    known_browser_types = ['chromium', 'firefox', 'webkit']
    unless known_browser_types.include?(browser_type)
      raise ArgumentError, "Unknown browser type: #{browser_type}. Known types are: #{known_browser_types.join(', ')}"
    end

    require 'playwright/web_socket_client'
    require 'playwright/web_socket_transport'

    transport = WebSocketTransport.new(
      ws_endpoint: ws_endpoint,
      headers: { 'x-playwright-browser' => browser_type },
    )
    connection = Connection.new(transport)
    connection.mark_as_remote
    connection.async_run

    execution =
      begin
        playwright = connection.initialize_playwright
        browser = playwright.send(:pre_launched_browser)
        browser.send(:connect_to_browser_type, playwright.send(browser_type), nil)
        browser.send(:should_close_connection_on_close!)
        Execution.new(connection, PlaywrightApi.wrap(playwright), PlaywrightApi.wrap(browser))
      rescue
        connection.stop
        raise
      end

    if block
      begin
        block.call(execution.browser)
      ensure
        execution.stop
      end
    else
      execution
    end
  end

  # Connects to Playwright server, launched by `npx playwright launch-server --browser _android` or `playwright._android.launchServer()`
  #
  # Playwright.connect_to_android_server('ws://....') do |browser|
  #   page = browser.new_page
  #   ...
  # end
  #
  # @experimental
  module_function def connect_to_android_server(ws_endpoint, &block)
    require 'playwright/web_socket_client'
    require 'playwright/web_socket_transport'

    transport = WebSocketTransport.new(ws_endpoint: ws_endpoint)
    connection = Connection.new(transport)
    connection.mark_as_remote
    connection.async_run

    execution =
      begin
        playwright = connection.initialize_playwright
        android_device = playwright.send(:pre_connected_android_device)
        android_device.should_close_connection_on_close!
        AndroidExecution.new(connection, PlaywrightApi.wrap(playwright), PlaywrightApi.wrap(android_device))
      rescue
        connection.stop
        raise
      end

    if block
      begin
        block.call(execution.device)
      ensure
        execution.stop
      end
    else
      execution
    end
  end
end
