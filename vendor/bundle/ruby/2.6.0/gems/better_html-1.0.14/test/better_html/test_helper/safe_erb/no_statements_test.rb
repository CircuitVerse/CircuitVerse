require 'test_helper'
require 'better_html/test_helper/safe_erb/no_statements'

module BetterHtml
  module TestHelper
    module SafeErb
      class NoStatementsTest < ActiveSupport::TestCase
        setup do
          @config = BetterHtml::Config.new(
            javascript_safe_methods: ['j', 'escape_javascript', 'to_json'],
            javascript_attribute_names: [/\Aon/i, 'data-eval'],
          )
        end

        test "<script> tag with non executable content type is ignored" do
          errors = validate(<<-EOF).errors
            <script type="text/html">
              <a onclick="<%= unsafe %>">
            </script>
          EOF

          assert_predicate errors, :empty?
        end

        test "statements not allowed in script tags" do
          errors = validate(<<-EOF).errors
            <script type="text/javascript">
              <% if foo? %>
                bla
              <% end %>
            </script>
          EOF

          assert_equal 1, errors.size
          assert_equal "<% if foo? %>", errors.first.location.source
          assert_equal "erb statement not allowed here; did you mean '<%=' ?", errors.first.message
        end

        test "statements not allowed in script without specified type" do
          errors = validate(<<-EOF).errors
            <script>
              <% if foo? %>
                bla
              <% end %>
            </script>
          EOF

          assert_equal 1, errors.size
          assert_equal "<% if foo? %>", errors.first.location.source
          assert_equal "erb statement not allowed here; did you mean '<%=' ?", errors.first.message
        end

        test "statements not allowed in javascript template" do
          errors = validate(<<-JS, template_language: :javascript).errors
            <% if foo %>
              bla
            <% end %>
          JS

          assert_equal 1, errors.size
          assert_equal "<% if foo %>", errors.first.location.source
          assert_equal "erb statement not allowed here; did you mean '<%=' ?", errors.first.message
        end

        test "erb comments allowed in scripts" do
          errors = validate(<<-EOF).errors
            <script type="text/javascript">
              <%# comment %>
            </script>
          EOF

          assert_predicate errors, :empty?
        end

        test "script tag without content" do
          errors = validate(<<-EOF).errors
            <script type="text/javascript"></script>
          EOF

          assert_predicate errors, :empty?
        end

        test "statement after script regression" do
          errors = validate(<<-EOF).errors
            <script type="text/javascript">
              foo()
            </script>
            <% if condition? %>
          EOF

          assert_predicate errors, :empty?
        end

        test "end statements are allowed in script tags" do
          errors = validate(<<-EOF).errors
            <script type="text/template">
              <%= ui_form do %>
                <div></div>
              <% end %>
            </script>
          EOF

          assert_predicate errors, :empty?
        end

        test "statements are allowed in text/html tags" do
          errors = validate(<<-EOF).errors
            <script type="text/html">
              <% if condition? %>
                <div></div>
              <% end %>
            </script>
          EOF

          assert_predicate errors, :empty?
        end

        private
        def validate(data, template_language: :html)
          parser = BetterHtml::Parser.new(buffer(data), template_language: template_language)
          tester = BetterHtml::TestHelper::SafeErb::NoStatements.new(parser, config: @config)
          tester.validate
          tester
        end
      end
    end
  end
end
