require 'test_helper'
require 'better_html/test_helper/safe_lodash_tester'

module BetterHtml
  module TestHelper
    class SafeLodashTesterTest < ActiveSupport::TestCase
      test "interpolate in attribute not allowed" do
        errors = parse(<<-EOF).errors
          <div class="[%! foo %]">
        EOF

        assert_equal 1, errors.size
        assert_equal '[%! foo %]', errors.first.location.source
        assert_equal "lodash interpolation with '[%!' inside html attribute is never safe", errors.first.message
      end

      test "escape in attribute is allowed" do
        errors = parse(<<-EOF).errors
          <div class="[%= foo %]">
        EOF

        assert_predicate errors, :empty?
      end

      test "escape in javascript attribute not allowed" do
        errors = parse(<<-EOF).errors
          <div onclick="[%= foo %]">
        EOF

        assert_equal 1, errors.size
        assert_equal '[%= foo %]', errors.first.location.source
        assert_equal "lodash interpolation in javascript attribute `onclick` must call `JSON.stringify(foo)`", errors.first.message
      end

      test "escape in javascript attribute with JSON.stringify is allowed" do
        errors = parse(<<-EOF).errors
          <div onclick="[%= JSON.stringify(foo) %]">
        EOF

        assert_predicate errors, :empty?
      end

      test "script tag is not allowed" do
        errors = parse(<<-EOF).errors
          <script type="text/javascript"></script>
        EOF

        assert_equal 1, errors.size
        assert_equal '<script type="text/javascript">', errors.first.location.source
        assert_equal "No script tags allowed nested in lodash templates", errors.first.message
      end

      test "script tag names are unescaped" do
        errors = parse(<<-EOF).errors
          <script type="text/j&#x61;v&#x61;script"></script>
        EOF

        assert_equal 1, errors.size
        assert_equal '<script type="text/j&#x61;v&#x61;script">', errors.first.location.source
        assert_equal "No script tags allowed nested in lodash templates", errors.first.message
      end

      test "statement not allowed in attribute name" do
        errors = parse(<<-EOF).errors
          <div class[% if (foo) %]="foo">
        EOF

        assert_equal 1, errors.size
        assert_equal '[% if (foo) %]', errors.first.location.source
        assert_equal "javascript statement not allowed here; did you mean '[%=' ?", errors.first.message
      end

      test "statement not allowed in attribute value" do
        errors = parse(<<-EOF).errors
          <div class="foo[% if (foo) %]">
        EOF

        assert_equal 1, errors.size
        assert_equal '[% if (foo) %]', errors.first.location.source
        assert_equal "javascript statement not allowed here; did you mean '[%=' ?", errors.first.message
      end

      private

      def parse(data)
        SafeLodashTester::Tester.new(buffer(data))
      end
    end
  end
end
