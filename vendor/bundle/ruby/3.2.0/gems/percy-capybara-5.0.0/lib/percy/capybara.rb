require 'net/http'
require 'uri'
require 'capybara/dsl'
require_relative './version'

module PercyCapybara
  CLIENT_INFO = "percy-capybara/#{VERSION}".freeze
  ENV_INFO = "capybara/#{Capybara::VERSION} ruby/#{RUBY_VERSION}".freeze

  PERCY_DEBUG = ENV['PERCY_LOGLEVEL'] == 'debug'
  PERCY_SERVER_ADDRESS = ENV['PERCY_SERVER_ADDRESS'] || 'http://localhost:5338'
  PERCY_LABEL = "[\u001b[35m" + (PERCY_DEBUG ? 'percy:capybara' : 'percy') + "\u001b[39m]"

  private_constant :CLIENT_INFO
  private_constant :ENV_INFO

  # Take a DOM snapshot and post it to the snapshot endpoint
  def percy_snapshot(name, options = {})
    return unless percy_enabled?

    page = Capybara.current_session

    begin
      page.evaluate_script(fetch_percy_dom)
      dom_snapshot = page
        .evaluate_script("(function() { return PercyDOM.serialize(#{options.to_json}) })()")

      response = fetch('percy/snapshot',
        name: name,
        url: page.current_url,
        dom_snapshot: dom_snapshot,
        client_info: CLIENT_INFO,
        environment_info: ENV_INFO,
        **options,)

      unless response.body.to_json['success']
        raise StandardError, data['error']
      end
    rescue StandardError => e
      log("Could not take DOM snapshot '#{name}'")

      if PERCY_DEBUG then log(e) end
    end
  end

  # Determine if the Percy server is running, caching the result so it is only checked once
  private def percy_enabled?
    return @percy_enabled unless @percy_enabled.nil?

    begin
      response = fetch('percy/healthcheck')
      version = response['x-percy-core-version']

      if version.nil?
        log('You may be using @percy/agent ' \
            'which is no longer supported by this SDK. ' \
            'Please uninstall @percy/agent and install @percy/cli instead. ' \
            'https://docs.percy.io/docs/migrating-to-percy-cli')
        @percy_enabled = false
        return false
      end

      if version.split('.')[0] != '1'
        log("Unsupported Percy CLI version, #{version}")
        @percy_enabled = false
        return false
      end

      @percy_enabled = true
      true
    rescue StandardError => e
      log('Percy is not running, disabling snapshots')

      if PERCY_DEBUG then log(e) end
      @percy_enabled = false
      false
    end
  end

  # Fetch the @percy/dom script, caching the result so it is only fetched once
  private def fetch_percy_dom
    return @percy_dom unless @percy_dom.nil?

    response = fetch('percy/dom.js')
    @percy_dom = response.body
  end

  private def log(msg)
    puts "#{PERCY_LABEL} #{msg}"
  end

  # Make an HTTP request (GET,POST) using Ruby's Net::HTTP. If `data` is present,
  # `fetch` will POST as JSON.
  private def fetch(url, data = nil)
    uri = URI("#{PERCY_SERVER_ADDRESS}/#{url}")

    response = if data
      Net::HTTP.post(uri, data.to_json)
    else
      Net::HTTP.get_response(uri)
    end

    unless response.is_a? Net::HTTPSuccess
      raise StandardError, "Failed with HTTP error code: #{response.code}"
    end

    response
  end
end

# Add the `percy_snapshot` method to the the Capybara session class
# `page.percy_snapshot('name', { options })`
Capybara::Session.class_eval { include PercyCapybara }
