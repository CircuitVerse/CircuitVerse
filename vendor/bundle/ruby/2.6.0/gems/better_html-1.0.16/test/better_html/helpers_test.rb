require 'test_helper'

class BetterHtml::HelpersTest < ActiveSupport::TestCase
  include BetterHtml::Helpers

  test "html_attributes return a HtmlAttributes object" do
    assert_equal BetterHtml::HtmlAttributes, html_attributes(foo: "bar").class
  end

  test "html_attributes are formatted as string" do
    assert_equal 'foo="bar" baz="qux"',
      html_attributes(foo: "bar", baz: "qux").to_s
  end

  test "html_attributes keys cannot contain invalid characters" do
    e = assert_raises(ArgumentError) do
      html_attributes("invalid key": "bar", baz: "qux").to_s
    end
    assert_equal "Attribute names must match the pattern /\\A[a-zA-Z0-9\\-\\:]+\\z/", e.message
  end

  test "#html_attributes does not accept incorrectly escaped html_safe values" do
    e = assert_raises(ArgumentError) do
      html_attributes('something': 'with "> double quote'.html_safe).to_s
    end
    assert_equal "The value provided for attribute 'something' contains a `\"` character which is not allowed. "\
      "Did you call .html_safe without properly escaping this data?", e.message
  end

  test "#html_attributes accepts correctly escaped html_safe values" do
    assert_equal 'something="with &quot;&gt; double quote"',
      html_attributes('something': CGI.escapeHTML('with "> double quote').html_safe).to_s
  end

  test "#html_attributes escapes non-html_safe values" do
    assert_equal 'something="with &quot;&gt; double quote"',
      html_attributes('something': 'with "> double quote').to_s
  end

  test "#html_attributes accepts nil values as value-less attributes" do
    assert_equal 'data-thing data-other-thing',
      html_attributes('data-thing': nil, 'data-other-thing': nil).to_s
  end

  test "#html_attributes empty string value is output" do
    assert_equal 'data-thing="" data-other-thing=""',
      html_attributes('data-thing': "", 'data-other-thing': "").to_s
  end
end
