require 'test_helper'
require 'better_html/test_helper/safe_erb/script_interpolation'

module BetterHtml
  module TestHelper
    module SafeErb
      class ScriptInterpolationTest < ActiveSupport::TestCase
        setup do
          @config = BetterHtml::Config.new(
            javascript_safe_methods: ['j', 'escape_javascript', 'to_json'],
            javascript_attribute_names: [/\Aon/i, 'data-eval'],
          )
        end

        test "multi line erb comments in text" do
          errors = validate(<<-EOF).errors
            text
            <%#
               this is a nice comment
               !@\#{$%?&*()}
            %>
          EOF

          assert_predicate errors, :empty?
        end

        test "multi line erb comments in html attribute" do
          errors = validate(<<-EOF).errors
            <div title="
              <%#
                 this is a comment right in the middle of an attribute for some reason
              %>
              ">
          EOF

          assert_predicate errors, :empty?
        end

        test "unsafe erb in <script> tag without type" do
          errors = validate(<<-EOF).errors
            <script>
              if (a < 1) { <%= unsafe %> }
            </script>
          EOF

          assert_equal 1, errors.size
          assert_equal '<%= unsafe %>', errors.first.location.source
          assert_equal "erb interpolation in javascript tag must call '(...).to_json'", errors.first.message
        end

        test "unsafe erb in javascript template" do
          errors = validate(<<-JS, template_language: :javascript).errors
            if (a < 1) { <%= unsafe %> }
          JS

          assert_equal 1, errors.size
          assert_equal '<%= unsafe %>', errors.first.location.source
          assert_equal "erb interpolation in javascript tag must call '(...).to_json'", errors.first.message
        end

        test "<script> tag without calls is unsafe" do
          errors = validate(<<-EOF).errors
            <script type="text/javascript">
              if (a < 1) { <%= "unsafe" %> }
            </script>
          EOF

          assert_equal 1, errors.size
          assert_equal '<%= "unsafe" %>', errors.first.location.source
          assert_equal "erb interpolation in javascript tag must call '(...).to_json'", errors.first.message
        end

        test "javascript template without calls is unsafe" do
          errors = validate(<<-JS, template_language: :javascript).errors
            if (a < 1) { <%= "unsafe" %> }
          JS

          assert_equal 1, errors.size
          assert_equal '<%= "unsafe" %>', errors.first.location.source
          assert_equal "erb interpolation in javascript tag must call '(...).to_json'", errors.first.message
        end

        test "unsafe erb in <script> tag with text/javascript content type" do
          errors = validate(<<-EOF).errors
            <script type="text/javascript">
              if (a < 1) { <%= unsafe %> }
            </script>
          EOF

          assert_equal 1, errors.size
          assert_equal '<%= unsafe %>', errors.first.location.source
          assert_equal "erb interpolation in javascript tag must call '(...).to_json'", errors.first.message
        end

        test "<script> with to_json is safe" do
          errors = validate(<<-EOF).errors
            <script type="text/javascript">
              <%= unsafe.to_json %>
            </script>
          EOF

          assert_predicate errors, :empty?
        end

        test "javascript template with to_json is safe" do
          errors = validate(<<-JS, template_language: :javascript).errors
            <%= unsafe.to_json %>
          JS

          assert_predicate errors, :empty?
        end

        test "<script> with raw and to_json is safe" do
          errors = validate(<<-EOF).errors
            <script type="text/javascript">
              <%= raw unsafe.to_json %>
            </script>
          EOF

          assert_predicate errors, :empty?
        end

        test "javascript template with raw and to_json is safe" do
          errors = validate(<<-JS, template_language: :javascript).errors
            <%= raw unsafe.to_json %>
          JS

          assert_predicate errors, :empty?
        end

        test "ivar missing .to_json is unsafe" do
          errors = validate('<script><%= @feature.html_safe %></script>').errors

          assert_equal 1, errors.size
          assert_equal "<%= @feature.html_safe %>", errors.first.location.source
          assert_equal "erb interpolation in javascript tag must call '(...).to_json'", errors.first.message
        end

        private
        def validate(data, template_language: :html)
          parser = BetterHtml::Parser.new(buffer(data), template_language: template_language)
          tester = BetterHtml::TestHelper::SafeErb::ScriptInterpolation.new(parser, config: @config)
          tester.validate
          tester
        end
      end
    end
  end
end
