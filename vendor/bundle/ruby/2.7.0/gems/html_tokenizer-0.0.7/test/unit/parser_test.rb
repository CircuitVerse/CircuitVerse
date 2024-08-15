require "minitest/autorun"
require "html_tokenizer"

class HtmlTokenizer::ParserTest < Minitest::Test
  def test_empty_context
    parse
    assert_equal :none, @parser.context
  end

  def test_open_tag
    parse("<div")
    assert_equal :tag_name, @parser.context
    assert_equal "div", @parser.tag_name
    assert_equal false, @parser.closing_tag?
  end

  def test_open_attribute_value
    parse('<div "foo')
    assert_equal :quoted_value, @parser.context
    assert_equal 'foo', @parser.attribute_value
    assert_equal '"', @parser.quote_character
    parse('bar"')
    assert_equal :space_after_attribute, @parser.context
    assert_equal 'foobar', @parser.attribute_value
    assert_equal true, @parser.attribute_quoted?
    assert_equal '"', @parser.quote_character
  end

  def test_multi_part_namespace_tag
    parse("<foo:")
    assert_equal "foo:", @parser.tag_name
    parse("bar")
    assert_equal "foo:bar", @parser.tag_name
  end

  def test_solidus_after_tag_name
    parse("<foo/")
    assert_equal "foo", @parser.tag_name
    assert_equal :tag_end, @parser.context
  end

  def test_whitespace_after_tag_name
    parse("<foo ")
    assert_equal "foo", @parser.tag_name
    assert_equal :tag, @parser.context
  end

  def test_context_is_tag_name_just_after_solidus
    parse("</")
    assert_equal :tag_name, @parser.context
    assert_equal true, @parser.closing_tag?
  end

  def test_close_tag
    parse("<div", ">")
    assert_equal :none, @parser.context
  end

  def test_attribute_name
    parse("<div foo")
    assert_equal "div", @parser.tag_name
    assert_equal :attribute_name, @parser.context
    assert_equal "foo", @parser.attribute_name
    parse("bla")
    assert_equal "foobla", @parser.attribute_name
  end

  def test_attribute_name_and_close
    parse("<div foo>")
    assert_equal "div", @parser.tag_name
    assert_equal "foo", @parser.attribute_name
    assert_nil @parser.attribute_value
    assert_equal :none, @parser.context
  end

  def test_attribute_solidus_close
    parse("<div foo/>")
    assert_equal "div", @parser.tag_name
    assert_equal "foo", @parser.attribute_name
    assert_nil @parser.attribute_value
    assert_equal :none, @parser.context
    assert_equal false, @parser.closing_tag?
    assert_equal true, @parser.self_closing_tag?
  end

  def test_attribute_value_solidus_close
    parse("<div 'foo'/>")
    assert_equal "div", @parser.tag_name
    assert_nil @parser.attribute_name
    assert_equal "foo", @parser.attribute_value
    assert_equal true, @parser.attribute_quoted?
    assert_equal :none, @parser.context
    assert_equal false, @parser.closing_tag?
    assert_equal true, @parser.self_closing_tag?
  end

  def test_attribute_value_and_tag_close
    parse('<div "foo">')
    assert_equal "div", @parser.tag_name
    assert_nil @parser.attribute_name
    assert_equal 'foo', @parser.attribute_value
    assert_equal true, @parser.attribute_quoted?
    assert_equal '"', @parser.quote_character
    assert_equal :none, @parser.context
    assert_equal false, @parser.closing_tag?
    assert_equal false, @parser.self_closing_tag?
  end

  def test_attribute_value_equal_and_tag_close
    parse("<div foo=>")
    assert_equal "div", @parser.tag_name
    assert_equal "foo", @parser.attribute_name
    assert_nil @parser.attribute_value
    assert_equal :none, @parser.context
    assert_equal false, @parser.closing_tag?
    assert_equal false, @parser.self_closing_tag?
  end

  def test_attribute_value_open_quote
    parse("<div '")
    assert_nil @parser.attribute_name
    assert_nil @parser.attribute_value
    assert_equal true, @parser.attribute_quoted?
    assert_equal "'", @parser.quote_character
    assert_equal :quoted_value, @parser.context
  end

  def test_attribute_name_and_value_open_quote
    parse("<div foo='")
    assert_nil @parser.attribute_value
    assert_equal true, @parser.attribute_quoted?
    assert_equal "'", @parser.quote_character
    assert_equal :quoted_value, @parser.context
  end

  def test_attribute_value_open
    parse("<div foo=")
    assert_equal "div", @parser.tag_name
    assert_equal "foo", @parser.attribute_name
    assert_nil @parser.attribute_value
    assert_equal :after_equal, @parser.context
  end

  def test_attribute_name_with_solidus
    parse("<div foo=/")
    assert_equal "foo", @parser.attribute_name
    assert_equal "/", @parser.attribute_value
    assert_equal false, @parser.attribute_quoted?
    assert_nil @parser.quote_character
    assert_equal :unquoted_value, @parser.context
  end

  def test_solidus_anywhere_doesnt_affect_closing_flags
    parse("<div / >")
    assert_equal "div", @parser.tag_name
    assert_equal false, @parser.closing_tag?
    assert_equal false, @parser.self_closing_tag?
  end

  def test_solidus_at_beginning_and_end_affect_closing_flags
    parse("</div/>")
    assert_equal "div", @parser.tag_name
    assert_equal true, @parser.closing_tag?
    assert_equal true, @parser.self_closing_tag?
  end

  def test_attribute_name_with_solidus_and_name
    parse("<div foo=/bar")
    assert_equal "foo", @parser.attribute_name
    assert_equal "/bar", @parser.attribute_value
    assert_equal false, @parser.attribute_quoted?
    assert_nil @parser.quote_character
    assert_equal :unquoted_value, @parser.context
  end

  def test_attribute_with_value_with_solidus
    parse("<div foo='bar'")
    assert_equal "foo", @parser.attribute_name
    assert_equal "bar", @parser.attribute_value
    assert_equal :space_after_attribute, @parser.context
    parse("/baz")
    assert_equal "baz", @parser.attribute_name
    assert_nil @parser.attribute_value
    assert_equal false, @parser.attribute_quoted?
    assert_nil @parser.quote_character
    assert_equal :attribute_name, @parser.context
  end

  def test_attribute_with_unquoted_value
    parse("<div foo=bar")
    assert_equal "foo", @parser.attribute_name
    assert_equal "bar", @parser.attribute_value
    assert_equal false, @parser.attribute_quoted?
    assert_nil @parser.quote_character
    assert_equal :unquoted_value, @parser.context
  end

  def test_attribute_with_unquoted_value_tag_end
    parse("<div foo=bar>")
    assert_equal "foo", @parser.attribute_name
    assert_equal "bar", @parser.attribute_value
    assert_equal false, @parser.attribute_quoted?
    assert_nil @parser.quote_character
    assert_equal :none, @parser.context
  end

  def test_attribute_with_unquoted_value_with_solidus
    parse("<div foo=ba", "r", "/baz")
    assert_equal "foo", @parser.attribute_name
    assert_equal "bar/baz", @parser.attribute_value
    assert_equal false, @parser.attribute_quoted?
    assert_nil @parser.quote_character
    assert_equal :unquoted_value, @parser.context
  end

  def test_attribute_with_unquoted_value_with_space
    parse("<div foo=ba", "r", " baz")
    assert_equal "baz", @parser.attribute_name
    assert_nil @parser.attribute_value
    assert_equal false, @parser.attribute_quoted?
    assert_nil @parser.quote_character
    assert_equal :attribute_name, @parser.context
  end

  def test_attribute_with_multipart_unquoted_value
    parse("<div foo=ba", "r", "&baz")
    assert_equal "foo", @parser.attribute_name
    assert_equal "bar&baz", @parser.attribute_value
    assert_equal false, @parser.attribute_quoted?
    assert_nil @parser.quote_character
    assert_equal :unquoted_value, @parser.context
  end

  def test_attribute_name_incomplete
    parse("<div foo")
    assert_equal "foo", @parser.attribute_name
    assert_equal :attribute_name, @parser.context
  end

  def test_space_after_attribute_name_switches_context
    parse("<div foo ")
    assert_equal "foo", @parser.attribute_name
    assert_equal :after_attribute_name, @parser.context
  end

  def test_solidus_after_attribute_name_switches_context
    parse("<div foo/")
    assert_equal "foo", @parser.attribute_name
    assert_equal :tag_end, @parser.context
  end

  def test_attribute_name_is_complete_after_equal
    parse("<div foo=")
    assert_equal "foo", @parser.attribute_name
    assert_equal :after_equal, @parser.context
  end

  def test_attribute_name_without_value
    parse("<div foo ")
    assert_equal "foo", @parser.attribute_name
    assert_nil @parser.attribute_value
    assert_equal :after_attribute_name, @parser.context
  end

  def test_attribute_name_are_separated_by_space
    parse("<div foo bar")
    assert_equal "bar", @parser.attribute_name
    assert_nil @parser.attribute_value
    assert_equal :attribute_name, @parser.context
  end

  def test_comment_context
    parse("<!--")
    assert_equal :comment, @parser.context
    assert_nil @parser.comment_text
  end

  def test_cdata_context
    parse("<![CDATA[")
    assert_equal :cdata, @parser.context
    assert_nil @parser.cdata_text
  end

  def test_comment_text
    parse("<!-- foo")
    assert_equal :comment, @parser.context
    assert_equal " foo", @parser.comment_text
  end

  def test_cdata_text
    parse("<![CDATA[ foo")
    assert_equal :cdata, @parser.context
    assert_equal " foo", @parser.cdata_text
  end

  def test_multipart_comment
    parse("<!-- f", "oo", "bar")
    assert_equal :comment, @parser.context
    assert_equal " foobar", @parser.comment_text
  end

  def test_multipart_cdata
    parse("<![CDATA[ f", "oo", "bar")
    assert_equal :cdata, @parser.context
    assert_equal " foobar", @parser.cdata_text
  end

  def test_comment_end
    parse("<!-- foo -->")
    assert_equal :none, @parser.context
    assert_equal " foo ", @parser.comment_text
  end

  def test_cdata_end
    parse("<![CDATA[ foo ]]>")
    assert_equal :none, @parser.context
    assert_equal " foo ", @parser.cdata_text
  end

  def test_plaintext_never_stops_parsing
    parse("<plaintext>")
    assert_equal :rawtext, @parser.context
    assert_equal "plaintext", @parser.tag_name
    assert_nil @parser.rawtext_text

    parse("some", "<text")
    assert_equal :rawtext, @parser.context
    assert_equal "some<text", @parser.rawtext_text

    parse("<plaintext")
    assert_equal :rawtext, @parser.context
    assert_equal "some<text<plaintext", @parser.rawtext_text

    parse("</plaintext>")
    assert_equal :rawtext, @parser.context
    assert_equal "some<text<plaintext</plaintext>", @parser.rawtext_text
  end

  %w(title textarea style xmp iframe noembed noframes).each do |name|
    define_method "test_#{name}_rawtext" do
      parse("<#{name}>")
      assert_equal :rawtext, @parser.context
      assert_equal name, @parser.tag_name
      assert_nil @parser.rawtext_text

      parse("some", "<text")
      assert_equal :rawtext, @parser.context
      assert_equal "some<text", @parser.rawtext_text

      parse("<#{name}")
      assert_equal :rawtext, @parser.context
      assert_equal "some<text<#{name}", @parser.rawtext_text

      parse("</#{name}")
      assert_equal :tag_name, @parser.context
      assert_equal "some<text<#{name}", @parser.rawtext_text

      parse(">")
      assert_equal :none, @parser.context
      assert_equal "some<text<#{name}", @parser.rawtext_text
    end
  end

  def test_script_rawtext
    parse("<script>data data data")
    assert_equal :rawtext, @parser.context
    assert_equal "script", @parser.tag_name
    assert_equal "data data data", @parser.rawtext_text
    parse("</script")
    assert_equal :tag_name, @parser.context
    assert_equal "script", @parser.tag_name
    parse(">")
    assert_equal :none, @parser.context
  end

  def test_consecutive_scripts
    parse("<script>foo\n</script>\n<script>bar</script>\n bla")
    assert_equal :none, @parser.context
  end

  def test_end_of_script_regression
    html = "<script><!</script>"
    parse(html)
    assert_equal :none, @parser.context
  end

  def test_document_length
    @parser = HtmlTokenizer::Parser.new
    assert_equal 0, @parser.document_length
    parse("abcdef")
    assert_equal 6, @parser.document_length
    parse("abcdef")
    assert_equal 12, @parser.document_length
  end

  def test_document_method
    @parser = HtmlTokenizer::Parser.new
    assert_nil @parser.document
    parse("abcdef")
    assert_equal "abcdef", @parser.document
    parse("abcdef")
    assert_equal "abcdefabcdef", @parser.document
  end

  def test_yields_raw_tokens_when_block_given
    tokens = []
    parse("<foo>") do |*token|
      tokens << token
    end
    assert_equal [[:tag_start, 0, 1, 1, 0], [:tag_name, 1, 4, 1, 1], [:tag_end, 4, 5, 1, 4]], tokens
  end

  def test_yields_line_and_column_numbers
    tokens = []
    parse("<\n>") do |*token|
      tokens << token
    end
    assert_equal [[:tag_start, 0, 1, 1, 0], [:whitespace, 1, 2, 1, 1], [:tag_end, 2, 3, 2, 0]], tokens
  end

  def test_append_placeholder_adjusts_line_and_column_numbers_but_does_not_parse
    @parser = HtmlTokenizer::Parser.new
    tokens = []
    @parser.parse("foo\n") do |*token|
      tokens << token
    end
    @parser.append_placeholder("<%= some ruby do\n  foo\nend %>\n") do |*token|
      tokens << token
    end
    @parser.parse("bar\n") do |*token|
      tokens << token
    end
    assert_equal [[:text, 0, 4, 1, 0], [:text, 34, 38, 5, 0]], tokens
  end

  def test_solidus_or_tag_name_error
    parse('<>')
    assert_equal 1, @parser.errors_count
    assert_equal "expected '/' or tag name", @parser.errors.first.to_s
    assert_equal 1, @parser.errors.first.position
    assert_equal 1, @parser.errors.first.line
    assert_equal 1, @parser.errors.first.column
  end

  def test_solidus_or_tag_name_error_2
    parse('< ')
    assert_equal 1, @parser.errors_count
    assert_equal "expected '/' or tag name", @parser.errors.first.to_s
    assert_equal 1, @parser.errors.first.position
    assert_equal 1, @parser.errors.first.line
    assert_equal 1, @parser.errors.first.column
  end

  def test_tag_error
    parse('<foo =')
    assert_equal 1, @parser.errors_count
    assert_equal "expected whitespace, '>', attribute name or value", @parser.errors.first.to_s
    assert_equal 5, @parser.errors.first.position
    assert_equal 1, @parser.errors.first.line
    assert_equal 5, @parser.errors.first.column
  end

  def test_tag_end_error
    parse('<foo /x')
    assert_equal 1, @parser.errors_count
    assert_equal "expected '>' after '/'", @parser.errors.first.to_s
    assert_equal 6, @parser.errors.first.position
    assert_equal 1, @parser.errors.first.line
    assert_equal 6, @parser.errors.first.column
  end

  def test_tag_end_error_2
    parse('<foo / ')
    assert_equal 1, @parser.errors_count
    assert_equal "expected '>' after '/'", @parser.errors.first.to_s
    assert_equal 6, @parser.errors.first.position
    assert_equal 1, @parser.errors.first.line
    assert_equal 6, @parser.errors.first.column
  end

  def test_attribute_name_error
    parse('<foo bar~')
    assert_equal 2, @parser.errors_count
    assert_equal "expected whitespace, '>' or '=' after attribute name", @parser.errors[0].to_s
    assert_equal 8, @parser.errors.first.position
    assert_equal 1, @parser.errors[0].line
    assert_equal 8, @parser.errors[0].column
    assert_equal "expected whitespace, '>', attribute name or value", @parser.errors[1].to_s
    assert_equal 8, @parser.errors.first.position
    assert_equal 1, @parser.errors[1].line
    assert_equal 8, @parser.errors[1].column
  end

  def test_attribute_whitespace_or_equal_error
    parse('<foo bar ~')
    assert_equal 2, @parser.errors_count
    assert_equal "expected '/', '>', \", ' or '=' after attribute name", @parser.errors[0].to_s
    assert_equal 1, @parser.errors[0].line
    assert_equal 9, @parser.errors[0].column
    assert_equal "expected whitespace, '>', attribute name or value", @parser.errors[1].to_s
    assert_equal 9, @parser.errors.first.position
    assert_equal 1, @parser.errors[1].line
    assert_equal 9, @parser.errors[1].column
  end

  def test_attribute_whitespace_or_equal_error_2
    parse('<foo bar = >')
    assert_equal 1, @parser.errors_count
    assert_equal "expected attribute value after '='", @parser.errors.first.to_s
    assert_equal 11, @parser.errors.first.position
    assert_equal 1, @parser.errors.first.line
    assert_equal 11, @parser.errors.first.column
  end

  def test_attribute_after_quoted_value
    parse('<foo bar=""x')
    assert_equal 1, @parser.errors_count
    assert_equal "expected space after attribute value", @parser.errors.first.to_s
    assert_equal 11, @parser.errors.first.position
    assert_equal 1, @parser.errors.first.line
    assert_equal 11, @parser.errors.first.column
  end

  def test_attribute_with_mutlibyte_characters
    data = ["<div title", "='your store’s'>"]
    tokens = []
    parse(*data) { |name, start, stop| tokens << [name, start, stop, data.join[start...stop]] }
    assert_equal "div", @parser.tag_name
    assert_equal "title", @parser.attribute_name
    assert_equal "your store’s", @parser.attribute_value
    assert_equal data.join, @parser.document
    assert_equal data.join.size, @parser.document_length
    assert_equal data.join.size, @parser.column_number
    assert_equal [
      [:tag_start, 0, 1, "<"],
      [:tag_name, 1, 4, "div"],
      [:whitespace, 4, 5, " "],
      [:attribute_name, 5, 10, "title"],
      [:equal, 10, 11, "="],
      [:attribute_quoted_value_start, 11, 12, "'"],
      [:attribute_quoted_value, 12, 24, "your store’s"],
      [:attribute_quoted_value_end, 24, 25, "'"],
      [:tag_end, 25, 26, ">"],
    ], tokens
  end

  def test_valid_syntaxes
    parse(
      '<div>',
      '<div />',
      '<div/>',
      '<div data-thing>',
      '<div data-thing />',
      '<div data-thing/>',
      '<div "value">',
      '<div "value" />',
      '<div "value"/>',
      '<div data-thing   =   "value">',
      '<div data-thing="value">',
      '<div data-thing="value"/>',
      '<div data-thing data-other-thing="value">',
      '<div data-thing data-other-thing="value"/>',
      "<div \n\t\r data-thing \n\t\r data-other-thing='value'>",
      '<div data-thing "value">',
      '<div data-thing "value"/>',
      '<div data-thing "value" />',
      '<div "value" data-thing>',
      '<div "value" data-thing/>',
      '<div foo=unquoted=bla/>',
      '<div foo=unquoted=bla />',
      '<div foo=unquoted=bla>',
      '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    )
    assert_equal 0, @parser.errors_count, "Expected no errors: #{@parser.errors}"
  end

  def test_doctype_without_space
    parse('<!DOCTYPE')
    assert_equal "!DOCTYPE", @parser.tag_name
    parse('foo')
    assert_equal "!DOCTYPEfoo", @parser.tag_name

    assert_equal 0, @parser.errors_count, "Expected no errors: #{@parser.errors}"
  end

  private

  def parse(*parts, &block)
    @parser ||= HtmlTokenizer::Parser.new
    parts.each do |part|
      @parser.parse(part, &block)
    end
  end
end
