# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    SUPPORTED_VERSIONS =
    {
      # Rubies
      :mri =>
      {
        :type        => :ruby,
        :name        => "MRI",
        :supported   => ["2.0.0", "~>2.1.0", "~>2.2.0", "~>2.3.0", "~>2.4.0", "~>2.5.0", "~>2.6.0", "~>2.7.0"],
        :deprecated  => ["1.8.6", "1.8.7", "1.9.2", "1.9.3"],
        :url         => "https://www.ruby-lang.org",
        :feed        => "https://www.ruby-lang.org/en/feeds/news.rss",
        :notes       => ["Last supported agent for 1.8.7, 1.9.2, and 1.9.3 was 3.18.1.330.",
                         "Last supported agent on 1.8.6 was 3.6.8.168."]
      },
      :jruby =>
      {
        :type        => :ruby,
        :name        => "JRuby",
        :supported   => ["~>9.0", "~>9.1"],
        :deprecated  => ["~>1.7.0"],
        :url         => "http://jruby.org",
        :feed        => "http://jruby.org/atom.xml",
        :notes       => ["Last supported agent for ~>1.7.0 was 3.18.1.330."]
      },

      # App servers
      :passenger =>
      {
        :type        => :app_server,
        :supported   => ["~>2.2", "~>3.0", "~>4.0"],
        :url         => "http://www.phusionpassenger.com/",
        :feed        => "http://rubygems.org/gems/passenger/versions.atom"
      },
      :thin =>
      {
        :type        => :app_server,
        :supported   => ["~>1.0"],
        :url         => "http://code.macournoyer.com/thin/",
        :feed        => "http://rubygems.org/gems/thin/versions.atom"
      },
      :unicorn =>
      {
        :type        => :app_server,
        :supported   => ["~>4.0"],
        :deprecated  => ["~>1.0", "~>2.0", "~>3.0"],
        :url         => "http://unicorn.bogomips.org/",
        :feed        => "http://rubygems.org/gems/unicorn/versions.atom"
      },
      :puma =>
      {
        :type        => :app_server,
        :supported   => ["~>2.0"],
        :deprecated  => ["~>1.0"],
        :url         => "http://puma.io/",
        :feed        => "http://rubygems.org/gems/puma/versions.atom"
      },
      :rainbows =>
      {
        :type        => :app_server,
        :name        => "rainbows!",
        :experimental=> ["4.5.0"],
        :url         => "http://rainbows.rubyforge.org/",
        :feed        => "http://rubygems.org/gems/rainbows/versions.atom"
      },
      :webrick =>
      {
        :type        => :app_server,
        :notes       => [ "Supported for all agent-supported versions of Ruby" ]
      },

      # Web frameworks
      :rails =>
      {
        :type        => :web,
        :supported   => ["~3.0.0", "~>3.1.0", "~>3.2.0", "~>4.0.0", "~>4.1.0", "~>4.2.0", "~>5.0.0", "~>5.1.0"],
        :deprecated  => ["~>2.0.0", "~>2.1.0", "~>2.2.0", "~>2.3.0"],
        :url         => "https://rubygems.org/gems/rails",
        :feed        => "https://rubygems.org/gems/rails/versions.atom",
        :notes       => ["Last supported agent for ~>2.1.0, ~>2.2.0, and ~>2.3.0 was 3.18.1.330.",
                         "Last supported agent for 2.0.x was 3.6.8.168."]
      },
      :sinatra =>
      {
        :type        => :web,
        :supported   => ["~>1.2.0", "~>1.3.0", "~>1.4.0", "~>2.0.0"],
        :url         => "https://rubygems.org/gems/sinatra",
        :feed        => "https://rubygems.org/gems/sinatra/versions.atom"
      },
      :padrino =>
      {
        :type        => :web,
        :supported   => ["~>0.10"],
        :url         => "https://rubygems.org/gems/padrino",
        :feed        => "https://rubygems.org/gems/padrino/versions.atom"
      },
      :rack =>
      {
        :type        => :web,
        :supported   => [">= 1.1.0"],
        :deprecated  => ["~>1.0.0"],
        :url         => "https://rubygems.org/gems/rack",
        :feed        => "https://rubygems.org/gems/rack/versions.atom"
      },
      :grape =>
      {
        :type        => :web,
        :supported   => [">= 0.2.0"],
        :url         => "https://rubygems.org/gems/grape",
        :feed        => "https://rubygems.org/gems/grape/versions.atom"
      },

      # Database
      :activerecord =>
      {
        :type        => :database,
        :supported   => ["~>3.0.0", "~>3.1.0", "~>3.2.0", "~>4.0.0", "~>4.1.0", "~>4.2.0", "~>5.0.0", "~>5.1.0", "~>6.0.0"],
        :deprecated  => ["~>2.0.0", "~>2.1.0", "~>2.2.0", "~>2.3.0",],
        :url         => "https://rubygems.org/gems/activerecord",
        :feed        => "https://rubygems.org/gems/activerecord/versions.atom",
        :notes       => ["Last supported agent for ~>2.1.0, ~>2.2.0, and ~>2.3.0 was 3.18.1.330.",
                         "Last supported agent for 2.0.x was 3.6.8.168."]
      },
      :datamapper =>
      {
        :type        => :database,
        :supported   => ["~>1.0"],
        :url         => "https://rubygems.org/gems/datamapper",
        :feed        => "https://rubygems.org/gems/datamapper/versions.atom"
      },
      :sequel =>
      {
        :type        => :database,
        :supported   => ["~>3.37", "~>4.0"],
        :url         => "https://rubygems.org/gems/sequel",
        :feed        => "https://rubygems.org/gems/sequel/versions.atom"
      },
      :mongo =>
      {
        :type        => :database,
        :supported   => ["~>1.8", "~>2.1"],
        :url         => "https://rubygems.org/gems/mongo",
        :feed        => "https://rubygems.org/gems/mongo/versions.atom"
      },
      :redis =>
      {
        :type        => :database,
        :supported   => ["~>3.0"],
        :url         => "https://rubygems.org/gems/redis",
        :feed        => "https://rubygems.org/gems/redis/versions.atom"
      },

      # Background Jobs
      :rake =>
      {
        :type        => :background,
        :supported   => ["~>10.0"],
        :url         => "https://rubygems.org/gems/rake",
        :feed        => "https://rubygems.org/gems/rake/versions.atom"
      },
      :resque =>
      {
        :type        => :background,
        :supported   => ["~>1.23.0"],
        :deprecated  => ["~>1.22.0"],
        :experimental=> [">= 2.0"],
        :url         => "https://rubygems.org/gems/resque",
        :feed        => "https://rubygems.org/gems/resque/versions.atom"
      },
      :sidekiq =>
      {
        :type        => :background,
        :supported   => ["~>2.8", "~>3.4.2", "~>4.0"],
        :url         => "https://rubygems.org/gems/sidekiq",
        :feed        => "https://rubygems.org/gems/sidekiq/versions.atom"
      },
      :delayed_job =>
      {
        :type        => :background,
        :supported   => ["~>2.0", "~>3.0", "~>4.0"],
        :url         => "https://rubygems.org/gems/delayed_job",
        :feed        => "https://rubygems.org/gems/delayed_job/versions.atom"
      },

      # HTTP Clients
      :curb =>
      {
        :type        => :http,
        :supported   => [ ">= 0.8.1" ],
        :url         => "https://rubygems.org/gems/curb",
        :feed        => "https://rubygems.org/gems/curb/versions.atom"
      },
      :excon =>
      {
        :type        => :http,
        :supported   => [ ">= 0.10.1" ],
        :url         => "https://rubygems.org/gems/excon",
        :feed        => "https://rubygems.org/gems/excon/versions.atom"
      },
      :httpclient =>
      {
        :type        => :http,
        :supported   => [ ">= 2.2.0"],
        :url         => "https://rubygems.org/gems/httpclient",
        :feed        => "https://rubygems.org/gems/httpclient/versions.atom"
      },
      :typhoeus =>
      {
        :type        => :http,
        :supported   => [ ">= 0.5.3"],
        :url         => "https://rubygems.org/gems/typhoeus",
        :feed        => "https://rubygems.org/gems/typhoeus/versions.atom"
      },
      :net_http =>
      {
        :type        => :http,
        :name        => "Net::HTTP",
        :notes       => [
          "Supported for all agent-supported versions of Ruby.",
          "For more information on supported HTTP clients see http://docs.newrelic.com/docs/ruby/ruby-http-clients."]
      },
      :httprb =>
      {
        :type        => :http,
        :supported   => [ ">= 0.9.9"],
        :url         => "https://rubygems.org/gems/http",
        :feed        => "https://rubygems.org/gems/http/versions.atom"
      },

      # Other
      :sunspot =>
      {
        :type        => :other,
        :url         => "https://rubygems.org/gems/sunspot",
        :feed        => "https://rubygems.org/gems/sunspot/versions.atom"
      },
      :acts_as_solr =>
      {
        :type        => :other,
        :url         => "https://rubygems.org/gems/acts_as_solr",
        :feed        => "https://rubygems.org/gems/acts_as_solr/versions.atom"
      },
      :dalli =>
      {
        :type        => :other,
        :url         => "https://rubygems.org/gems/dalli",
        :feed        => "https://rubygems.org/gems/dalli/versions.atom"
      },
      :'memcache-client' =>
      {
        :type        => :other,
        :url         => "https://rubygems.org/gems/memcache-client",
        :feed        => "https://rubygems.org/gems/memcache-client/versions.atom"
      },
      :authlogic =>
      {
        :type        => :other,
        :url         => "https://rubygems.org/gems/authlogic",
        :feed        => "https://rubygems.org/gems/authlogic/versions.atom"
      },
      :activemerchant =>
      {
        :type        => :other,
        :supported   => [ ">= 1.25.0"],
        :url         => "https://rubygems.org/gems/activemerchant",
        :feed        => "https://rubygems.org/gems/activemerchant/versions.atom"
      },
    }
  end
end
