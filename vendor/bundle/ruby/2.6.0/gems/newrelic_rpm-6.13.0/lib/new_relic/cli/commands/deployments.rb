# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

# This is a class for executing commands related to deployment
# events.  It runs without loading the rails environment

require 'yaml'
require 'net/http'
require 'rexml/document'
require 'new_relic/agent/hostname'

# We need to use the Control object but we don't want to load
# the rails/merb environment.  The defined? clause is so that
# it won't load it twice, something it does when run inside a test
require 'new_relic/control' unless defined? NewRelic::Control

class NewRelic::Cli::Deployments < NewRelic::Cli::Command
  attr_reader :control
  def self.command; "deployments"; end

  # Initialize the deployment uploader with command line args.
  # Use -h to see options.
  # When command_line_args is a hash, we are invoking directly and
  # it's treated as an options with optional string values for
  # :user, :description, :appname, :revision, :environment,
  # :license_key, and :changes.
  #
  # Will throw CommandFailed exception if there's any error.
  #
  def initialize command_line_args
    @control = NewRelic::Control.instance
    @environment = nil
    @changelog   = nil
    @user        = nil
    super(command_line_args)
    @description ||= @leftover && @leftover.join(" ")
    @user ||= ENV['USER']
    control.env = @environment if @environment

    load_yaml_from_env(control.env)
    @appname ||= NewRelic::Agent.config[:app_name][0] || control.env || 'development'
    @license_key ||= NewRelic::Agent.config[:license_key]

    setup_logging(control.env)
  end

  def load_yaml_from_env(env)
    yaml = NewRelic::Agent::Configuration::YamlSource.new(NewRelic::Agent.config[:config_path], env)
    if yaml.failed?
      messages = yaml.failures.flatten.map(&:to_s).join("\n")
      raise NewRelic::Cli::Command::CommandFailure.new("Error in loading newrelic.yml.\n#{messages}")
    end

    NewRelic::Agent.config.replace_or_add_config(yaml)
  end

  def setup_logging(env)
    NewRelic::Agent.logger = NewRelic::Agent::AgentLogger.new
    NewRelic::Agent.logger.info("Running Capistrano from '#{env}' environment for application '#{@appname}'")
  end

  # Run the Deployment upload in New Relic via Active Resource.
  # Will possibly print errors and exit the VM
  def run
    begin
      @description = nil if @description && @description.strip.empty?
      create_params = {}
      {
            :application_id => @appname,
            :host => NewRelic::Agent::Hostname.get,
            :description => @description,
            :user => @user,
            :revision => @revision,
            :changelog => @changelog
      }.each do |k, v|
        create_params["deployment[#{k}]"] = v unless v.nil? || v == ''
      end
      http = ::NewRelic::Agent::NewRelicService.new(nil, control.api_server).http_connection

      uri = "/deployments.xml"

      if @license_key.nil? || @license_key.empty?
        raise "license_key was not set in newrelic.yml for #{control.env}"
      end
      request = Net::HTTP::Post.new(uri, {'x-license-key' => @license_key})
      request.content_type = "application/octet-stream"

      request.set_form_data(create_params)

      response = http.request(request)

      if response.is_a? Net::HTTPSuccess
        info "Recorded deployment to '#{@appname}' (#{@description || Time.now })"
      else
        err_string = REXML::Document.new(response.body).elements['errors/error'].map(&:to_s).join("; ") rescue  response.message
        raise NewRelic::Cli::Command::CommandFailure, "Deployment not recorded: #{err_string}"
      end
    rescue SystemCallError, SocketError => e
      # These include Errno connection errors
      err_string = "Transient error attempting to connect to #{control.api_server} (#{e})"
      raise NewRelic::Cli::Command::CommandFailure.new(err_string)
    rescue NewRelic::Cli::Command::CommandFailure
      raise
    rescue => e
      err "Unexpected error attempting to connect to #{control.api_server}"
      info "#{e}: #{e.backtrace.join("\n   ")}"
      raise NewRelic::Cli::Command::CommandFailure.new(e.to_s)
    end
  end

  private

  def options
    OptionParser.new %Q{Usage: #{$0} #{self.class.command} [OPTIONS] ["description"] }, 40 do |o|
      o.separator "OPTIONS:"
      o.on("-a", "--appname=NAME", String,
             "Set the application name.",
             "Default is app_name setting in newrelic.yml") { | e | @appname = e }
      o.on("-e", "--environment=name", String,
               "Override the (RAILS|MERB|RUBY|RACK)_ENV setting",
               "currently: #{control.env}") { | e | @environment = e }
      o.on("-u", "--user=USER", String,
             "Specify the user deploying, for information only",
             "Default: #{@user || '<none>'}") { | u | @user = u }
      o.on("-r", "--revision=REV", String,
             "Specify the revision being deployed") { | r | @revision = r }
      o.on("-l", "--license-key=KEY", String,
             "Specify the license key of the account for the app being deployed") { | l | @license_key = l }
      o.on("-c", "--changes",
             "Read in a change log from the standard input") { @changelog = STDIN.read }
      yield o if block_given?
    end
  end


end
