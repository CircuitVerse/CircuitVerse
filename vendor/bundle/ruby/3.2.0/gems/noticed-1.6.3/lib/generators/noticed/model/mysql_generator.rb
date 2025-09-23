# frozen_string_literal: true

require "rails/generators/named_base"
require_relative "base_generator"

module Noticed
  module Generators
    module Model
      class MysqlGenerator < BaseGenerator
        private

        def json_column_type
          "json"
        end
      end
    end
  end
end
