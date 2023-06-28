require 'test_helper'
require 'better_html/test_helper/safe_erb/tag_interpolation'

module BetterHtml
  module TestHelper
    module SafeErb
      class TagInterpolationTest < ActiveSupport::TestCase
        setup do
          @config = BetterHtml::Config.new(
            javascript_safe_methods: ['j', 'escape_javascript', 'to_json'],
            javascript_attribute_names: [/\Aon/i, 'data-eval'],
          )
        end

        test "raw in <script> tag" do
          errors = validate(<<-EOF).errors
            <script>var myData = <%= raw(foo.to_json) %>;</script>
          EOF

          assert_equal 0, errors.size
        end

        test "raw in <style> tag" do
          errors = validate(<<-EOF).errors
            <style>@import url(<%= raw url_for("all.css") %>);</style>
          EOF

          assert_equal 0, errors.size
        end

        test "html_safe in <script> tag" do
          errors = validate(<<-EOF).errors
            <script>var myData = <%= foo.to_json.html_safe %>;</script>
          EOF

          assert_equal 0, errors.size
        end

        test "<%== in <script> tag" do
          errors = validate(<<-EOF).errors
            <script>var myData = <%== foo.to_json %>;</script>
          EOF

          assert_equal 0, errors.size
        end

        test "string without interpolation is safe" do
          errors = validate(<<-EOF).errors
            <a onclick="alert('<%= "something" %>')">
          EOF

          assert_equal 0, errors.size
        end

        test "string with interpolation" do
          errors = validate(<<-EOF).errors
            <a onclick="<%= "hello \#{name}" %>">
          EOF

          assert_equal 1, errors.size
          assert_equal 'name', errors.first.location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors.first.message
        end

        test "string with interpolation and ternary" do
          errors = validate(<<-EOF).errors
            <a onclick="<%= "hello \#{foo ? bar : baz}" if bla? %>">
          EOF

          assert_equal 2, errors.size

          assert_equal 'bar', errors[0].location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors[0].message

          assert_equal 'baz', errors[1].location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors[1].message
        end

        test "plain erb tag in html attribute" do
          errors = validate(<<-EOF).errors
            <a onclick="method(<%= unsafe %>)">
          EOF

          assert_equal 1, errors.size
          assert_equal 'unsafe', errors.first.location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors.first.message
        end

        test "to_json is safe in html attribute" do
          errors = validate(<<-EOF).errors
            <a onclick="method(<%= unsafe.to_json %>)">
          EOF
          assert_predicate errors, :empty?
        end

        test "ternary with safe javascript escaping" do
          errors = validate(<<-EOF).errors
            <a onclick="method(<%= foo ? bar.to_json : j(baz) %>)">
          EOF
          assert_predicate errors, :empty?
        end

        test "ternary with unsafe javascript escaping" do
          errors = validate(<<-EOF).errors
            <a onclick="method(<%= foo ? bar : j(baz) %>)">
          EOF

          assert_equal 1, errors.size
          assert_equal 'bar', errors.first.location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors.first.message
        end

        test "j is safe in html attribute" do
          errors = validate(<<-EOF).errors
            <a onclick="method('<%= j unsafe %>')">
          EOF
          assert_predicate errors, :empty?
        end

        test "j() is safe in html attribute" do
          errors = validate(<<-EOF).errors
            <a onclick="method('<%= j(unsafe) %>')">
          EOF
          assert_predicate errors, :empty?
        end

        test "escape_javascript is safe in html attribute" do
          errors = validate(<<-EOF).errors
            <a onclick="method(<%= escape_javascript unsafe %>)">
          EOF
          assert_predicate errors, :empty?
        end

        test "escape_javascript() is safe in html attribute" do
          errors = validate(<<-EOF).errors
            <a onclick="method(<%= escape_javascript(unsafe) %>)">
          EOF
          assert_predicate errors, :empty?
        end

        test "html_safe is never safe in html attribute, even non javascript attributes like href" do
          errors = validate(<<-EOF).errors
            <a href="<%= unsafe.html_safe %>">
          EOF

          assert_equal 1, errors.size
          assert_equal 'unsafe.html_safe', errors.first.location.source
          assert_equal "erb interpolation with '<%= (...).html_safe %>' in this context is never safe", errors.first.message
        end

        test "html_safe is never safe in html attribute, even with to_json" do
          errors = validate(<<-EOF).errors
            <a onclick="method(<%= unsafe.to_json.html_safe %>)">
          EOF

          assert_equal 2, errors.size
          assert_equal 'unsafe.to_json.html_safe', errors[0].location.source
          assert_equal "erb interpolation with '<%= (...).html_safe %>' in this context is never safe", errors[0].message
          assert_equal 'unsafe.to_json.html_safe', errors[1].location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors[1].message
        end

        test "<%== is never safe in html attribute, even non javascript attributes like href" do
          errors = validate(<<-EOF).errors
            <a href="<%== unsafe %>">
          EOF

          assert_equal 1, errors.size
          assert_equal '<%== unsafe %>', errors.first.location.source
          assert_includes "erb interpolation with '<%==' inside html attribute is never safe", errors.first.message
        end

        test "<%== is never safe in html attribute, even with to_json" do
          errors = validate(<<-EOF).errors
            <a onclick="method(<%== unsafe.to_json %>)">
          EOF

          assert_equal 1, errors.size
          assert_equal '<%== unsafe.to_json %>', errors.first.location.source
          assert_includes "erb interpolation with '<%==' inside html attribute is never safe", errors.first.message
        end

        test "raw is never safe in html attribute, even non javascript attributes like href" do
          errors = validate(<<-EOF).errors
            <a href="<%= raw unsafe %>">
          EOF

          assert_equal 1, errors.size
          assert_equal 'raw unsafe', errors.first.location.source
          assert_equal "erb interpolation with '<%= raw(...) %>' in this context is never safe", errors.first.message
        end

        test "raw is never safe in html attribute, even with to_json" do
          errors = validate(<<-EOF).errors
            <a onclick="method(<%= raw unsafe.to_json %>)">
          EOF

          assert_equal 2, errors.size
          assert_equal 'raw unsafe.to_json', errors[0].location.source
          assert_equal "erb interpolation with '<%= raw(...) %>' in this context is never safe", errors[0].message
          assert_equal 'raw unsafe.to_json', errors[1].location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors[1].message
        end

        test "unsafe javascript methods in helper calls with new hash syntax" do
          errors = validate(<<-EOF).errors
            <%= ui_my_helper(:foo, onclick: "alert(\#{unsafe})", onmouseover: "alert(\#{unsafe.to_json})") %>
          EOF

          assert_equal 1, errors.size
          assert_equal "unsafe", errors[0].location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors[0].message
        end

        test "unsafe javascript methods in helper calls with old hash syntax" do
          errors = validate(<<-EOF).errors
            <%= ui_my_helper(:foo, :onclick => "alert(\#{unsafe})") %>
          EOF

          assert_equal 1, errors.size
          assert_equal "unsafe", errors.first.location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors.first.message
        end

        test "unsafe javascript methods in helper calls with more than one level of nested hash and :dstr" do
          errors = validate(<<-EOF).errors
            <%= ui_my_helper(:foo, inner_html: { onclick: "foo \#{unsafe}" }) %>
          EOF

          assert_equal 1, errors.size
          assert_equal "unsafe", errors.first.location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors.first.message
        end

        test "safe javascript methods in helper calls with more than one level of nested hash and :dstr" do
          errors = validate(<<-EOF).errors
            <%= ui_my_helper(:foo, inner_html: { onclick: "foo \#{unsafe.to_json}" }) %>
          EOF

          assert_equal 0, errors.size
        end

        test "unsafe javascript methods in helper calls with string as key" do
          errors = validate(<<-EOF).errors
            <%= ui_my_helper(:foo, 'data-eval' => "alert(\#{unsafe})") %>
          EOF

          assert_equal 1, errors.size
          assert_equal "unsafe", errors.first.location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors.first.message
        end

        test "unsafe javascript methods in helper calls with nested data key" do
          errors = validate(<<-EOF).errors
            <%= ui_my_helper(:foo, data: { eval: "alert(\#{unsafe})" }) %>
          EOF

          assert_equal 1, errors.size
          assert_equal "unsafe", errors.first.location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors.first.message
        end

        test "unsafe javascript methods in helper calls with more than one level of nested data key" do
          errors = validate(<<-EOF).errors
            <%= ui_my_helper(:foo, inner_html: { data: { eval: "alert(\#{unsafe})" } }) %>
          EOF

          assert_equal 1, errors.size
          assert_equal "unsafe", errors.first.location.source
          assert_equal "erb interpolation in javascript attribute must be wrapped in safe helper such as '(...).to_json'", errors.first.message
        end

        test "using raw anywhere in helpers" do
          errors = validate(<<-EOF).errors
            <%= ui_my_helper(:foo, help_text: raw("foo")) %>
          EOF

          assert_equal 1, errors.size
          assert_equal "ui_my_helper(:foo, help_text: raw(\"foo\"))", errors.first.location.source
          assert_equal "erb interpolation with '<%= raw(...) %>' in this context is never safe", errors.first.message
        end

        test "using raw anywhere in html tags" do
          errors = validate(<<-EOF).errors
            <a "<%= raw("hello") %>">
          EOF

          assert_equal 1, errors.size
          assert_equal "raw(\"hello\")", errors.first.location.source
          assert_equal "erb interpolation with '<%= raw(...) %>' in this context is never safe", errors.first.message
        end

        private
        def validate(data, template_language: :html)
          parser = BetterHtml::Parser.new(buffer(data), template_language: template_language)
          tester = BetterHtml::TestHelper::SafeErb::TagInterpolation.new(parser, config: @config)
          tester.validate
          tester
        end
      end
    end
  end
end
