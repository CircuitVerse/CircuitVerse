require "minitest/autorun"
require "html_tokenizer"

class HtmlTokenizer::TokenizerTest < Minitest::Test
  def test_closing_tag_without_start_is_text
    assert_equal [
      [:text, ">"],
    ], tokenize(">")
    assert_equal [
      [:tag_start, "<"], [:tag_name, "foo"], [:tag_end, ">"], [:text, ">"],
    ], tokenize("<foo>>")
  end

  def test_tokenize_text
    result = tokenize("\n    hello world\n    ")
    assert_equal [[:text, "\n    hello world\n    "]], result
  end

  def test_namespace_tag_name_multipart
    assert_equal [
      [:tag_start, "<"], [:tag_name, "foo:"], [:tag_name, "bar"],
    ], tokenize("<foo:", "bar")
  end

  def test_tokenize_doctype
    assert_equal [
      [:tag_start, "<"], [:tag_name, "!DOCTYPE"], [:whitespace, " "],
      [:attribute_name, "html"], [:tag_end, ">"]
    ], tokenize("<!DOCTYPE html>")
  end

  def test_tokenize_multiple_elements
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:tag_end, ">"],
      [:text, " bla "],
      [:tag_start, "<"], [:tag_name, "strong"], [:tag_end, ">"]
    ], tokenize("<div> bla <strong>")
  end

  def test_tokenize_complex_doctype
    text = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
    assert_equal [
      [:tag_start, "<"], [:tag_name, "!DOCTYPE"], [:whitespace, " "],
      [:attribute_name, "html"], [:whitespace, " "],
      [:attribute_name, "PUBLIC"], [:whitespace, " "],
      [:attribute_quoted_value_start, "\""], [:attribute_quoted_value, "-//W3C//DTD XHTML 1.0 Transitional//EN"], [:attribute_quoted_value_end, "\""],
      [:whitespace, " "],
      [:attribute_quoted_value_start, "\""], [:attribute_quoted_value, "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"], [:attribute_quoted_value_end, "\""],
      [:tag_end, ">"]
    ], tokenize(text)
  end

  def test_tokenize_html_comment
    result = tokenize("<!-- COMMENT -->")
    assert_equal [[:comment_start, "<!--"], [:text, " COMMENT "], [:comment_end, "-->"]], result
  end

  def test_tokenize_comment_with_newlines
    result = tokenize <<-EOF
      <!-- debug: <%== @unsafe %> -->
    EOF

    assert_equal [
      [:text, "      "], [:comment_start, "<!--"],
      [:text, " debug: <%== @unsafe %> "],
      [:comment_end, "-->"], [:text, "\n"]
    ], result
  end

  def test_tokenize_cdata_section
    result = tokenize("<![CDATA[  bla bla <!&@#> foo ]]>")
    assert_equal [[:cdata_start, "<![CDATA["], [:text, "  bla bla <!&@#> foo "], [:cdata_end, "]]>"]], result
  end

  def test_tokenizer_cdata_regression
    result = tokenize("<![CDATA[ foo ", " baz ]]>")
    assert_equal [[:cdata_start, "<![CDATA["],
      [:text, " foo "], [:text, " baz "], [:cdata_end, "]]>"]], result
  end

  def test_tokenizer_comment_regression
    result = tokenize("<!-- foo ", " baz -->")
    assert_equal [[:comment_start, "<!--"],
      [:text, " foo "], [:text, " baz "], [:comment_end, "-->"]], result
  end

  def test_tokenizer_parse_tag_after_comment_regression
    result = tokenize("<!-- foo -->  <li>")
    assert_equal [[:comment_start, "<!--"], [:text, " foo "], [:comment_end, "-->"],
      [:text, "  "], [:tag_start, "<"], [:tag_name, "li"], [:tag_end, ">"]], result
  end

  def test_tokenize_basic_tag
    result = tokenize("<div>")
    assert_equal [[:tag_start, "<"], [:tag_name, "div"], [:tag_end, ">"]], result
  end

  def test_tokenize_namespaced_tag
    result = tokenize("<ns:foo>")
    assert_equal [[:tag_start, "<"], [:tag_name, "ns:foo"], [:tag_end, ">"]], result
  end

  def test_tokenize_tag_with_lt
    result = tokenize("<a<b>")
    assert_equal [[:tag_start, "<"], [:tag_name, "a<b"], [:tag_end, ">"]], result
  end

  def test_tokenize_tag_multipart_name
    result = tokenize("<d", "iv", ">")
    assert_equal [[:tag_start, "<"], [:tag_name, "d"], [:tag_name, "iv"], [:tag_end, ">"]], result
  end

  def test_tokenize_tag_name_ending_with_slash
    result = tokenize("<div/1>")
    assert_equal [[:tag_start, "<"], [:tag_name, "div"], [:solidus, "/"], [:attribute_name, "1"], [:tag_end, ">"]], result
  end

  def test_tokenize_empty_tag
    result = tokenize("<>")
    assert_equal [[:tag_start, "<"], [:tag_end, ">"]], result
  end

  def test_tokenize_tag_with_solidus
    result = tokenize("</>")
    assert_equal [[:tag_start, "<"], [:solidus, "/"], [:tag_end, ">"]], result
  end

  def test_tokenize_end_tag
    result = tokenize("</div>")
    assert_equal [[:tag_start, "<"], [:solidus, "/"], [:tag_name, "div"], [:tag_end, ">"]], result
  end

  def test_tokenize_tag_attribute_with_double_quote
    result = tokenize('<div foo="bar">')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_quoted_value_start, "\""], [:attribute_quoted_value, "bar"], [:attribute_quoted_value_end, "\""],
      [:tag_end, ">"]
    ], result
  end

  def test_tokenize_unquoted_attributes_separated_with_solidus
    result = tokenize('<div foo=1/bar=2>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_unquoted_value, "1/bar=2"],
      [:tag_end, ">"]
    ], result
  end

  def test_tokenize_quoted_attributes_separated_with_solidus
    result = tokenize('<div foo="1"/bar="2">')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_quoted_value_start, "\""], [:attribute_quoted_value, "1"], [:attribute_quoted_value_end, "\""],
      [:solidus, "/"],
      [:attribute_name, "bar"], [:equal, "="], [:attribute_quoted_value_start, "\""], [:attribute_quoted_value, "2"], [:attribute_quoted_value_end, "\""],
      [:tag_end, ">"]
    ], result
  end

  def test_tokenize_tag_attribute_without_space
    result = tokenize('<div foo="bar"baz>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_quoted_value_start, "\""], [:attribute_quoted_value, "bar"], [:attribute_quoted_value_end, "\""],
      [:attribute_name, "baz"],
      [:tag_end, ">"]
    ], result
  end

  def test_tokenize_multipart_unquoted_attribute
    result = tokenize('<div foo=', 'bar', 'baz>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_unquoted_value, "bar"],
      [:attribute_unquoted_value, "baz"], [:tag_end, ">"]
    ], result
  end

  def test_tokenize_quoted_attribute_separately
    result = tokenize('<div foo=', "'bar'", '>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_quoted_value_start, "'"], [:attribute_quoted_value, "bar"], [:attribute_quoted_value_end, "'"],
      [:tag_end, ">"]
    ], result
  end

  def test_tokenize_quoted_attribute_in_multiple_parts
    result = tokenize('<div foo=', "'bar", "baz'", '>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_quoted_value_start, "'"], [:attribute_quoted_value, "bar"], [:attribute_quoted_value, "baz"], [:attribute_quoted_value_end, "'"],
      [:tag_end, ">"]
    ], result
  end

  def test_tokenize_tag_attribute_with_single_quote
    result = tokenize("<div foo='bar'>")
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_quoted_value_start, "'"], [:attribute_quoted_value, "bar"], [:attribute_quoted_value_end, "'"],
      [:tag_end, ">"]
    ], result
  end

  def test_tokenize_tag_attribute_with_no_quotes
    result = tokenize("<div foo=bla bar=blo>")
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_unquoted_value, "bla"], [:whitespace, " "],
      [:attribute_name, "bar"], [:equal, "="], [:attribute_unquoted_value, "blo"],
      [:tag_end, ">"]
    ], result
  end

  def test_tokenize_double_equals
    result = tokenize("<div foo=blabar=blo>")
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_unquoted_value, "blabar=blo"],
      [:tag_end, ">"]
    ], result
  end

  def test_tokenize_closing_tag
    result = tokenize('<div foo="bar" />')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "foo"], [:equal, "="], [:attribute_quoted_value_start, "\""], [:attribute_quoted_value, "bar"], [:attribute_quoted_value_end, "\""], [:whitespace, " "],
      [:solidus, "/"], [:tag_end, ">"]
    ], result
  end

  def test_tokenize_script_tag
    result = tokenize('<script>foo <b> bar</script>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "script"], [:tag_end, ">"],
      [:text, "foo "], [:text, "<b"], [:text, "> bar"],
      [:tag_start, "<"], [:solidus, "/"], [:tag_name, "script"], [:tag_end, ">"],
    ], result
  end

  def test_tokenize_textarea_tag
    result = tokenize('<textarea>hello</textarea>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "textarea"], [:tag_end, ">"],
      [:text, "hello"],
      [:tag_start, "<"], [:solidus, "/"], [:tag_name, "textarea"], [:tag_end, ">"],
    ], result
  end

  def test_tokenize_style_tag
    result = tokenize('<style></div></style>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "style"], [:tag_end, ">"],
      [:text, "</div"], [:text, ">"],
      [:tag_start, "<"], [:solidus, "/"], [:tag_name, "style"], [:tag_end, ">"],
    ], result
  end

  def test_tokenize_script_containing_html
    result = tokenize('<script type="text/html">foo <b> bar</script>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "script"], [:whitespace, " "],
      [:attribute_name, "type"], [:equal, "="], [:attribute_quoted_value_start, "\""], [:attribute_quoted_value, "text/html"], [:attribute_quoted_value_end, "\""],
      [:tag_end, ">"],
      [:text, "foo "], [:text, "<b"], [:text, "> bar"],
      [:tag_start, "<"], [:solidus, "/"], [:tag_name, "script"], [:tag_end, ">"],
    ], result
  end

  def test_end_of_tag_on_newline
    data = ["\
          <div define=\"{credential_96_credential1: new Shopify.ProviderCredentials()}\"
                  ", "", ">"]
    result = tokenize(*data)
    assert_equal [
      [:text, "          "],
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "], [:attribute_name, "define"], [:equal, "="], [:attribute_quoted_value_start, "\""], [:attribute_quoted_value, "{credential_96_credential1: new Shopify.ProviderCredentials()}"], [:attribute_quoted_value_end, "\""],
      [:whitespace, "\n                  "], [:tag_end, ">"]
    ], result
  end

  def test_tokenize_multi_part_attribute_name
    result = tokenize('<div data-', 'shipping', '-type>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "div"], [:whitespace, " "],
      [:attribute_name, "data-"], [:attribute_name, "shipping"], [:attribute_name, "-type"],
      [:tag_end, ">"],
    ], result
  end

  def test_tokenize_attribute_name_with_space_before_equal
    result = tokenize('<a href ="http://www.cra-arc.gc.ca/tx/bsnss/tpcs/gst-tps/menu-eng.html">GST/HST</a>')
    assert_equal [
      [:tag_start, "<"], [:tag_name, "a"], [:whitespace, " "],
      [:attribute_name, "href"], [:whitespace, " "], [:equal, "="],
      [:attribute_quoted_value_start, "\""], [:attribute_quoted_value, "http://www.cra-arc.gc.ca/tx/bsnss/tpcs/gst-tps/menu-eng.html"], [:attribute_quoted_value_end, "\""],
      [:tag_end, ">"], [:text, "GST/HST"],
      [:tag_start, "<"], [:solidus, "/"], [:tag_name, "a"], [:tag_end, ">"]
    ], result
  end

  def test_raise_in_block
    @tokenizer = HtmlTokenizer::Tokenizer.new
    10.times do
      e = assert_raises(RuntimeError) do
        @tokenizer.tokenize("<>") do |part|
          raise RuntimeError, "something went wrong"
        end
      end
      assert_equal "something went wrong", e.message
    end
  end

  def test_tokenize_end_of_script_regression
    result = tokenize("<script><</script>")
    assert_equal [
      [:tag_start, "<"], [:tag_name, "script"], [:tag_end, ">"],
      [:text, "<"],
      [:tag_start, "<"], [:solidus, "/"], [:tag_name, "script"], [:tag_end, ">"]
    ], result
  end

  def test_html_with_mutlibyte_characters
    data = "<div title='your store’s'>foo</div>"
    result = tokenize(data)
    assert_equal [
      [:tag_start, "<"],
      [:tag_name, "div"],
      [:whitespace, " "],
      [:attribute_name, "title"],
      [:equal, "="],
      [:attribute_quoted_value_start, "'"],
      [:attribute_quoted_value, "your store’s"],
      [:attribute_quoted_value_end, "'"],
      [:tag_end, ">"],
      [:text, "foo"],
      [:tag_start, "<"],
      [:solidus, "/"],
      [:tag_name, "div"],
      [:tag_end, ">"],
    ], result
  end

  private

  def tokenize(*parts)
    tokens = []
    @tokenizer = HtmlTokenizer::Tokenizer.new
    parts.each do |part|
      @tokenizer.tokenize(part) { |name, start, stop| tokens << [name, part[start...stop]] }
    end
    tokens
  end
end
