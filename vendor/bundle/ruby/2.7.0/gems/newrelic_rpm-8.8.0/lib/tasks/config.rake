namespace :newrelic do
  namespace :config do
    desc "Describe available New Relic configuration settings."

    GENERAL = "general"
    DISABLING = "disabling"
    ATTRIBUTES = "attributes"

    # these configuration options are not able to be set using environment variables
    NON_ENV_CONFIGS = ['error_collector.ignore_classes', 'error_collector.ignore_messages', 'error_collector.expected_classes', 'error_collector.expected_messages']

    SECTION_DESCRIPTIONS = {
      GENERAL => 'These settings are available for agent configuration. Some settings depend on your New Relic subscription level.',
      DISABLING => 'Use these settings to toggle instrumentation types during agent startup.',
      ATTRIBUTES => '[Attributes](/docs/features/agent-attributes) are key-value pairs containing information that determines the properties of an event or transaction. These key-value pairs can be viewed within transaction traces in APM, traced errors in APM, transaction events in dashboards, and page views in dashboards. You can customize exactly which attributes will be sent to each of these destinations',
      "transaction_tracer" => 'The [transaction traces](/docs/apm/traces/transaction-traces/transaction-traces) feature collects detailed information from a selection of transactions, including a summary of the calling sequence, a breakdown of time spent, and a list of SQL queries and their query plans (on mysql and postgresql). Available features depend on your New Relic subscription level.',
      "error_collector" => "The agent collects and reports all uncaught exceptions by default. These configuration options allow you to customize the error collection.\n\nFor information on ignored and expected errors, [see this page on Error Analytics in APM](/docs/agents/manage-apm-agents/agent-data/manage-errors-apm-collect-ignore-or-mark-expected/). To set expected errors via the `NewRelic::Agent.notice_error` Ruby method, [consult the Ruby Agent API](/docs/agents/ruby-agent/api-guides/sending-handled-errors-new-relic/).",
      "browser_monitoring" => "The browser monitoring [page load timing](/docs/browser/new-relic-browser/page-load-timing/page-load-timing-process) feature (sometimes referred to as real user monitoring or RUM) gives you insight into the performance real users are experiencing with your website. This is accomplished by measuring the time it takes for your users' browsers to download and render your web pages by injecting a small amount of JavaScript code into the header and footer of each page.",
      "analytics_events" => '[New Relic dashboards](/docs/query-your-data/explore-query-data/dashboards/introduction-new-relic-one-dashboards) is a resource to gather and visualize data about your software and what it says about your business. With it you can quickly and easily create real-time dashboards to get immediate answers about end-user experiences, clickstreams, mobile activities, and server transactions.'
    }

    NAME_OVERRIDES = {
      "slow_sql" => "Slow SQL",
      "custom_insights_events" => "Custom Events"
    }

    def output(format)
      config_hash = build_config_hash
      sections = flatten_config_hash(config_hash)

      puts build_erb(format).result(binding).split("\n").map(&:rstrip).join("\n").gsub('.  ', '. ')
      sections # silences unused warning to return this
    end

    def build_config_hash
      sections = Hash.new { |hash, key| hash[key] = [] }
      NewRelic::Agent::Configuration::DEFAULTS.each do |key, value|
        next unless value[:public]

        section_key = GENERAL
        key = key.to_s
        components = key.split(".")

        if key.match(/^disable_/) # "disable_httpclient"
          section_key = DISABLING
        elsif components.length >= 2 && !(components[1] == "attributes") # "analytics_events.enabled"
          section_key = components.first
        elsif components[1] == "attributes" # "transaction_tracer.attributes.enabled"
          section_key = ATTRIBUTES
        end

        sections[section_key] << {
          :key => key,
          :type => format_type(value[:type]),
          :description => format_description(value),
          :default => format_default_value(value),
          :env_var => format_env_var(key)
        }
      end
      sections
    end

    def flatten_config_hash(config_hash)
      sections = []
      sections << pluck(GENERAL, config_hash)
      sections << pluck("transaction_tracer", config_hash)
      sections << pluck("error_collector", config_hash)
      sections << pluck("browser_monitoring", config_hash)
      sections << pluck("analytics_events", config_hash)
      sections << pluck("transaction_events", config_hash)
      sections << pluck("application_logging", config_hash)
      sections.concat(config_hash.to_a.sort_by { |a| a.first })

      add_data_to_sections(sections)

      sections
    end

    def add_data_to_sections(sections)
      sections.each do |section|
        section_key = section[0]
        section.insert(1, format_name(section_key))
        section.insert(2, SECTION_DESCRIPTIONS[section_key])
      end
    end

    def format_name(key)
      name = NAME_OVERRIDES[key]
      return name if name

      key.split("_")
        .each { |fragment| fragment[0] = fragment[0].upcase }
        .join(" ")
    end

    def format_type(type)
      if type == NewRelic::Agent::Configuration::Boolean
        "Boolean"
      else
        type
      end
    end

    def format_description(value)
      description = ''
      description += "<b>DEPRECATED</b> " if value[:deprecated]
      description += value[:description]
      description
    end

    def format_default_value(spec)
      return spec[:documentation_default] if !spec[:documentation_default].nil?
      if spec[:default].is_a?(Proc)
        '(Dynamic)'
      else
        "#{spec[:default].inspect}"
      end
    end

    def format_env_var(key)
      return "None" if NON_ENV_CONFIGS.include? key
      "NEW_RELIC_#{key.gsub(".", "_").upcase}"
    end

    def pluck(key, config_hash)
      value = config_hash.delete(key)
      [key, value]
    end

    def build_erb(format)
      require 'erb'
      path = File.join(File.dirname(__FILE__), "config.#{format}.erb")
      template = File.read(File.expand_path(path))
      ERB.new(template)
    end

    task :docs, [:format] => [] do |t, args|
      require File.expand_path(File.join(File.dirname(__FILE__), "..", "new_relic", "agent", "configuration", "default_source.rb"))
      format = args[:format] || "text"
      output(format)
    end
  end
end
