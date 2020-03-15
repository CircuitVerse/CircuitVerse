# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that mailers subclass ApplicationMailer with Rails 5.0.
      #
      # @example
      #
      #  # good
      #  class MyMailer < ApplicationMailer
      #    # ...
      #  end
      #
      #  # bad
      #  class MyMailer < ActionMailer::Base
      #    # ...
      #  end
      class ApplicationMailer < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 5.0

        MSG = 'Mailers should subclass `ApplicationMailer`.'
        SUPERCLASS = 'ApplicationMailer'
        BASE_PATTERN = '(const (const nil? :ActionMailer) :Base)'

        # rubocop:disable Layout/ClassStructure
        include RuboCop::Cop::EnforceSuperclass
        # rubocop:enable Layout/ClassStructure

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, self.class::SUPERCLASS)
          end
        end
      end
    end
  end
end
