# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module Datastores
      module Mongo
        def self.is_supported_version?
          # No version constant in < 2.0 versions of Mongo :(
          defined?(::Mongo) && (defined?(::Mongo::MongoClient) || is_monitoring_enabled?)
        end

        def self.is_monitoring_enabled?
          defined?(::Mongo::Monitoring) # @since 2.1.0
        end

        def self.is_unsupported_2x?
          defined?(::Mongo::VERSION) && Gem::Version.new(::Mongo::VERSION).segments[0] == 2 &&
            !self.is_monitoring_enabled?
        end

        def self.is_version_1_10_or_later?
          # Again, no VERSION constant in 1.x, so we have to rely on constant checks
          defined?(::Mongo::CollectionOperationWriter)
        end
      end
    end
  end
end
