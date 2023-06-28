# frozen_string_literal: true

module RuboCop
  module RSpec
    module Language
      # Helper methods to detect RSpec DSL used with send and block
      module NodePattern
        def send_pattern(string)
          "(send #rspec? #{string} ...)"
        end

        def block_pattern(string)
          "(block #{send_pattern(string)} ...)"
        end
      end
    end
  end
end
