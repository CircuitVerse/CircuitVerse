# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module ActiveRecord
      module Patches
        # Module to prepend to ActiveRecord::Base for instrumentation
        module Querying
          def self.prepended(base)
            class << base
              prepend ClassMethods
            end
          end

          # Contains ActiveRecord::Querying to be patched
          module ClassMethods
            method_name = ::ActiveRecord.version >= Gem::Version.new('7.0.0') ? :_query_by_sql : :find_by_sql

            define_method(method_name) do |*args, **kwargs, &block|
              tracer.in_span("#{self} query") do
                super(*args, **kwargs, &block)
              end
            end

            private

            def tracer
              ActiveRecord::Instrumentation.instance.tracer
            end
          end
        end
      end
    end
  end
end
