require 'test_helper'
require 'better_html/test_helper/safe_erb/no_javascript_tag_helper'

module BetterHtml
  module TestHelper
    module SafeErb
      class NoJavascriptTagHelperTest < ActiveSupport::TestCase
        setup do
          @config = BetterHtml::Config.new(
            javascript_safe_methods: ['j', 'escape_javascript', 'to_json'],
            javascript_attribute_names: [/\Aon/i, 'data-eval'],
          )
        end

        test "javascript_tag helper is not allowed because it parses as text and unsafe erb cannot be detected" do
          errors = validate(<<-EOF).errors
            <%= javascript_tag do %>
              if (a < 1) { <%= unsafe %> }
            <% end %>
          EOF

          assert_equal 1, errors.size
          assert_equal '<%= javascript_tag do %>', errors.first.location.source
          assert_includes "'javascript_tag do' syntax is deprecated; use inline <script> instead", errors.first.message
        end

        private
        def validate(data, template_language: :html)
          parser = BetterHtml::Parser.new(buffer(data), template_language: template_language)
          tester = BetterHtml::TestHelper::SafeErb::NoJavascriptTagHelper.new(parser, config: @config)
          tester.validate
          tester
        end
      end
    end
  end
end
