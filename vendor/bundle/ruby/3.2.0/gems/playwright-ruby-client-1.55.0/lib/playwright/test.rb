module Playwright
  # this module is responsible for running playwright assertions and integrating
  # with test frameworks.
  module Test
    @@expect_timeout = nil

    def self.expect_timeout
      @@expect_timeout || 5000 # default timeout is 5000ms
    end

    def self.expect_timeout=(timeout)
      @@expect_timeout = timeout
    end

    def self.with_timeout(expect_timeout, &block)
      old_timeout = @@expect_timeout
      @@expect_timeout = expect_timeout
      block.call
    ensure
      @@expect_timeout = old_timeout
    end

    # ref: https://github.com/microsoft/playwright-python/blob/main/playwright/sync_api/__init__.py#L90
    class Expect
      def initialize
        @default_expect_timeout = ::Playwright::Test.expect_timeout
      end

      def call(actual, is_not)
        case actual
        when Page
          PageAssertions.new(
            PageAssertionsImpl.new(
              actual,
              @default_expect_timeout,
              is_not,
              nil,
            )
          )
        when Locator
          LocatorAssertions.new(
            LocatorAssertionsImpl.new(
              actual,
              @default_expect_timeout,
              is_not,
              nil,
            )
          )
        else
          raise NotImplementedError.new("Only locator assertions are currently implemented")
        end
      end
    end

    module Matchers
      class PlaywrightMatcher
        def initialize(expectation_method, *args, **kwargs)
          @method = expectation_method
          @args = args
          @kwargs = kwargs
        end

        def matches?(actual)
          Expect.new.call(actual, false).send(@method, *@args, **@kwargs)
          true
        rescue AssertionError => e
          @failure_message = e.full_message
          false
        end

        def does_not_match?(actual)
          Expect.new.call(actual, true).send(@method, *@args, **@kwargs)
          true
        rescue AssertionError => e
          @failure_message = e.full_message
          false
        end

        def failure_message
          @failure_message
        end

        def failure_message_when_negated
          @failure_message
        end
      end
    end

    ALL_ASSERTIONS = PageAssertions.instance_methods(false) + LocatorAssertions.instance_methods(false)

    ALL_ASSERTIONS
      .map(&:to_s)
      .each do |method_name|
        # to_be_visible => be_visible
        # not_to_be_visible => not_be_visible
        root_method_name = method_name.gsub("to_", "")
        Matchers.send(:define_method, root_method_name) do |*args, **kwargs|
          Matchers::PlaywrightMatcher.new(method_name, *args, **kwargs)
        end
      end
  end
end
