require 'test_helper'
require 'better_html/errors'

module BetterHtml
  class ErrorsTest < ActiveSupport::TestCase
    test "add" do
      e = Errors.new
      e.add("foo")
      assert_equal 1, e.size
      assert_equal "foo", e.first
    end
  end
end
