require 'test_helper'
require 'better_html/parser'
require 'ast'

module BetterHtml
  class ParserTest < ActiveSupport::TestCase
    include ::AST::Sexp

    test "parse empty document" do
      tree = Parser.new(buffer(''))

      assert_equal s(:document), tree.ast
    end

    test "parser errors" do
      tree = Parser.new(buffer('<>'))

      assert_equal 1, tree.parser_errors.size
      assert_equal "expected '/' or tag name", tree.parser_errors[0].message
      assert_equal 1...2, tree.parser_errors[0].location.range
      assert_equal <<~EOF.strip, tree.parser_errors[0].location.line_source_with_underline
        <>
         ^
      EOF
    end

    test "consume cdata nodes" do
      code = "<![CDATA[ foo ]]>"
      tree = Parser.new(buffer(code))

      assert_equal s(:document, s(:cdata, ' foo ')), tree.ast
      assert_equal code, tree.ast.loc.source
    end

    test "unterminated cdata nodes are consumed until end" do
      code = "<![CDATA[ foo"
      tree = Parser.new(buffer(code))

      assert_equal s(:document, s(:cdata, ' foo')), tree.ast
      assert_equal code, tree.ast.loc.source
    end

    test "consume cdata with interpolation" do
      code = "<![CDATA[ foo <%= bar %> baz ]]>"
      tree = Parser.new(buffer(code))

      assert_equal s(:document,
        s(:cdata,
          " foo ",
          s(:erb, s(:indicator, '='), nil, s(:code, " bar "), nil),
          " baz "
        )),
        tree.ast
      assert_equal code, tree.ast.loc.source
    end

    test "consume comment nodes" do
      tree = Parser.new(buffer("<!-- foo -->"))

      assert_equal s(:document, s(:comment, ' foo ')), tree.ast
    end

    test "unterminated comment nodes are consumed until end" do
      tree = Parser.new(buffer("<!-- foo"))

      assert_equal s(:document, s(:comment, ' foo')), tree.ast
    end

    test "consume comment with interpolation" do
      tree = Parser.new(buffer("<!-- foo <%= bar %> baz -->"))

      assert_equal s(:document,
        s(:comment,
          " foo ",
          s(:erb, s(:indicator, "="), nil, s(:code, " bar "), nil),
          " baz "
        )),
        tree.ast
    end

    test "consume tag nodes" do
      tree = Parser.new(buffer("<div>"))
      assert_equal s(:document, s(:tag, nil, s(:tag_name, "div"), nil, nil)), tree.ast
    end

    test "tag without name" do
      tree = Parser.new(buffer("foo < bar"))
      assert_equal s(:document,
        s(:text, "foo "),
        s(:tag, nil, nil,
          s(:tag_attributes,
            s(:attribute, s(:attribute_name, 'bar'), nil, nil)
          ),
          nil
        )
      ), tree.ast
    end

    test "consume tag nodes with solidus" do
      tree = Parser.new(buffer("</div>"))
      assert_equal s(:document, s(:tag, s(:solidus), s(:tag_name, "div"), nil, nil)), tree.ast
    end

    test "sets self_closing when appropriate" do
      tree = Parser.new(buffer("<div/>"))
      assert_equal s(:document, s(:tag, nil, s(:tag_name, "div"), nil, s(:solidus))), tree.ast
    end

    test "consume tag nodes until name ends" do
      tree = Parser.new(buffer("<div/>"))
      assert_equal s(:document, s(:tag, nil, s(:tag_name, "div"), nil, s(:solidus))), tree.ast

      tree = Parser.new(buffer("<div "))
      assert_equal s(:document, s(:tag, nil, s(:tag_name, "div"), nil, nil)), tree.ast
    end

    test "consume tag nodes with interpolation" do
      tree = Parser.new(buffer("<ns:<%= name %>-thing>"))
      assert_equal s(:document,
        s(:tag,
          nil,
          s(:tag_name, "ns:", s(:erb, s(:indicator, "="), nil, s(:code, " name "), nil), "-thing"),
          nil,
          nil
        )), tree.ast
    end

    test "consume tag attributes with erb" do
      tree = Parser.new(buffer("<div class=foo <%= erb %> name=bar>"))
      assert_equal s(:document,
        s(:tag, nil,
          s(:tag_name, "div"),
          s(:tag_attributes,
            s(:attribute,
              s(:attribute_name, "class"),
              s(:equal),
              s(:attribute_value, "foo")
            ),
            s(:erb, s(:indicator, "="), nil,
              s(:code, " erb "), nil),
            s(:attribute,
              s(:attribute_name, "name"),
              s(:equal),
              s(:attribute_value, "bar")
            ),
          ),
          nil
        )), tree.ast
    end

    test "consume tag attributes nodes unquoted value" do
      tree = Parser.new(buffer("<div foo=bar>"))
      assert_equal s(:document,
        s(:tag, nil,
          s(:tag_name, "div"),
          s(:tag_attributes,
            s(:attribute,
              s(:attribute_name, "foo"),
              s(:equal),
              s(:attribute_value, "bar")
            )
          ),
          nil
        )), tree.ast
    end

    test "consume attributes without name" do
      tree = Parser.new(buffer("<div 'thing'>"))
      assert_equal s(:document,
        s(:tag, nil,
          s(:tag_name, "div"),
          s(:tag_attributes,
            s(:attribute,
              nil,
              nil,
              s(:attribute_value, s(:quote, "'"), "thing", s(:quote, "'"))
            )
          ),
          nil
        )), tree.ast
    end

    test "consume tag attributes nodes quoted value" do
      tree = Parser.new(buffer("<div foo=\"bar\">"))
      assert_equal s(:document,
        s(:tag, nil,
          s(:tag_name, "div"),
          s(:tag_attributes,
            s(:attribute,
              s(:attribute_name, "foo"),
              s(:equal),
              s(:attribute_value, s(:quote, "\""), "bar", s(:quote, "\""))
            )
          ),
          nil
        )), tree.ast
    end

    test "consume tag attributes nodes interpolation in name and value" do
      tree = Parser.new(buffer("<div data-<%= foo %>=\"some <%= value %> foo\">"))
      assert_equal s(:document,
        s(:tag, nil,
          s(:tag_name, "div"),
          s(:tag_attributes,
            s(:attribute,
              s(:attribute_name, "data-", s(:erb, s(:indicator, "="), nil, s(:code, " foo "), nil)),
              s(:equal),
              s(:attribute_value,
                s(:quote, "\""),
                "some ",
                s(:erb, s(:indicator, "="), nil, s(:code, " value "), nil),
                " foo",
                s(:quote, "\""),
              ),
            )
          ),
          nil
        )), tree.ast
    end

    test "consume text nodes" do
      tree = Parser.new(buffer("here is <%= some %> text"))

      assert_equal s(:document,
        s(:text,
          "here is ",
          s(:erb, s(:indicator, "="), nil, s(:code, " some "), nil),
          " text"
        )), tree.ast
    end

    test "javascript template parsing works" do
      tree = Parser.new(buffer("here is <%= some %> text"), template_language: :javascript)

      assert_equal s(:document,
        s(:text,
          "here is ",
          s(:erb, s(:indicator, "="), nil, s(:code, " some "), nil),
          " text"
        )), tree.ast
    end

    test "javascript template does not consume html tags" do
      tree = Parser.new(buffer("<div <%= some %> />"), template_language: :javascript)

      assert_equal s(:document,
        s(:text,
          "<div ",
          s(:erb, s(:indicator, "="), nil, s(:code, " some "), nil),
          " />"
        )), tree.ast
    end

    test "lodash template parsing works" do
      tree = Parser.new(buffer('<div class="[%= foo %]">'), template_language: :lodash)

      assert_equal s(:document,
        s(:tag,
          nil,
          s(:tag_name, "div"),
          s(:tag_attributes,
            s(:attribute,
              s(:attribute_name, "class"),
              s(:equal),
              s(:attribute_value,
                s(:quote, "\""),
                s(:lodash, s(:indicator, "="), s(:code, " foo ")),
                s(:quote, "\"")
              )
            )
          ),
          nil
        )
      ), tree.ast
    end

    test "nodes are all nested under document" do
      tree = Parser.new(buffer(<<~HTML))
        some text
        <!-- a comment -->
        some more text
        <%= an erb tag -%>
        <div class="foo">
          content
        </div>
      HTML

      assert_equal s(:document,
        s(:text, "some text\n"),
        s(:comment, " a comment "),
        s(:text,
          "\nsome more text\n",
          s(:erb, s(:indicator, '='), nil, s(:code, ' an erb tag '), s(:trim)),
          "\n"
        ),
        s(:tag,
          nil,
          s(:tag_name, "div"),
          s(:tag_attributes,
            s(:attribute,
              s(:attribute_name, "class"),
              s(:equal),
              s(:attribute_value, s(:quote, "\""), "foo", s(:quote, "\""))
            )
          ),
          nil
        ),
        s(:text, "\n  content\n"),
        s(:tag, s(:solidus), s(:tag_name, 'div'), nil, nil),
        s(:text, "\n"),
      ), tree.ast
    end
  end
end
