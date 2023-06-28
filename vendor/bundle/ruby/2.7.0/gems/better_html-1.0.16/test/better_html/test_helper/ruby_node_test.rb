require 'test_helper'
require 'better_html/test_helper/ruby_node'

module BetterHtml
  module TestHelper
    class RubyNodeTest < ActiveSupport::TestCase
      include ::AST::Sexp

      test "simple call" do
        expr = BetterHtml::TestHelper::RubyNode.parse("foo")
        assert_equal 1, expr.return_values.count
        assert_nil expr.return_values.first.receiver
        assert_equal :foo, expr.return_values.first.method_name
        assert_equal [], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "instance call" do
        expr = BetterHtml::TestHelper::RubyNode.parse("foo.bar")
        assert_equal 1, expr.return_values.count
        assert_equal s(:send, nil, :foo), expr.return_values.first.receiver
        assert_equal :bar, expr.return_values.first.method_name
        assert_equal [], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "instance call with arguments" do
        expr = BetterHtml::TestHelper::RubyNode.parse("foo(x).bar")
        assert_equal 1, expr.return_values.count
        assert_equal s(:send, nil, :foo, s(:send, nil, :x)), expr.return_values.first.receiver
        assert_equal :bar, expr.return_values.first.method_name
        assert_equal [], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "instance call with parenthesis" do
        expr = BetterHtml::TestHelper::RubyNode.parse("(foo).bar")
        assert_equal 1, expr.return_values.count
        assert_equal s(:begin,  s(:send, nil, :foo)), expr.return_values.first.receiver
        assert_equal :bar, expr.return_values.first.method_name
        assert_equal [], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "instance call with parenthesis 2" do
        expr = BetterHtml::TestHelper::RubyNode.parse("(foo)")
        assert_equal 1, expr.return_values.count
        assert_nil expr.return_values.first.receiver
        assert_equal :foo, expr.return_values.first.method_name
        assert_equal [], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "command call" do
        expr = BetterHtml::TestHelper::RubyNode.parse("foo bar")
        assert_equal 1, expr.return_values.count
        assert_nil expr.return_values.first.receiver
        assert_equal :foo, expr.return_values.first.method_name
        assert_equal [s(:send, nil, :bar)], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "command call with block" do
        expr = BetterHtml::TestHelper::RubyNode.parse("foo bar do")
        assert_equal 1, expr.return_values.count
        assert_nil expr.return_values.first.receiver
        assert_equal :foo, expr.return_values.first.method_name
        assert_equal [s(:send, nil, :bar)], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "call with parameters" do
        expr = BetterHtml::TestHelper::RubyNode.parse("foo(bar)")
        assert_equal 1, expr.return_values.count
        assert_nil expr.return_values.first.receiver
        assert_equal :foo, expr.return_values.first.method_name
        assert_equal [s(:send, nil, :bar)], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "instance call with parameters" do
        expr = BetterHtml::TestHelper::RubyNode.parse("foo.bar(baz, x)")
        assert_equal 1, expr.return_values.count
        assert_equal s(:send, nil, :foo), expr.return_values.first.receiver
        assert_equal :bar, expr.return_values.first.method_name
        assert_equal [s(:send, nil, :baz), s(:send, nil, :x)], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "call with parameters with if conditional modifier" do
        expr = BetterHtml::TestHelper::RubyNode.parse("foo(bar) if something?")
        assert_equal 1, expr.return_values.count
        assert_nil expr.return_values.first.receiver
        assert_equal :foo, expr.return_values.first.method_name
        assert_equal [s(:send, nil, :bar)], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "call with parameters with unless conditional modifier" do
        expr = BetterHtml::TestHelper::RubyNode.parse("foo(bar) unless something?")
        assert_equal 1, expr.return_values.count
        assert_nil expr.return_values.first.receiver
        assert_equal :foo, expr.return_values.first.method_name
        assert_equal [s(:send, nil, :bar)], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "expression call in ternary" do
        expr = BetterHtml::TestHelper::RubyNode.parse("something? ? foo : bar")
        assert_equal 2, expr.return_values.count
        refute_predicate expr, :static_return_value?

        assert_nil expr.return_values.to_a[0].receiver
        assert_equal :foo, expr.return_values.to_a[0].method_name
        assert_equal [], expr.return_values.to_a[0].arguments

        assert_nil expr.return_values.to_a[1].receiver
        assert_equal :bar, expr.return_values.to_a[1].method_name
        assert_equal [], expr.return_values.to_a[1].arguments
      end

      test "expression call with args in ternary" do
        expr = BetterHtml::TestHelper::RubyNode.parse("something? ? foo(x) : bar(x)")
        assert_equal 2, expr.return_values.count

        assert_nil expr.return_values.to_a[0].receiver
        assert_equal :foo, expr.return_values.to_a[0].method_name
        assert_equal [s(:send, nil, :x)], expr.return_values.to_a[0].arguments

        assert_nil expr.return_values.to_a[1].receiver
        assert_equal :bar, expr.return_values.to_a[1].method_name
        assert_equal [s(:send, nil, :x)], expr.return_values.to_a[1].arguments
        refute_predicate expr, :static_return_value?
      end

      test "string without interpolation" do
        expr = BetterHtml::TestHelper::RubyNode.parse('"foo"')
        assert_equal 1, expr.return_values.count
        assert_equal [s(:str, "foo")], expr.return_values.to_a
        assert_predicate expr, :static_return_value?
      end

      test "string with interpolation" do
        expr = BetterHtml::TestHelper::RubyNode.parse('"foo #{bar}"')
        method_calls = expr.return_values.select(&:method_call?)
        assert_equal 1, method_calls.count
        assert_nil method_calls.first.receiver
        assert_equal :bar, method_calls.first.method_name
        assert_equal [], method_calls.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "ternary in string with interpolation" do
        expr = BetterHtml::TestHelper::RubyNode.parse('"foo #{foo? ? bar : baz}"')
        method_calls = expr.return_values.select(&:method_call?)
        assert_equal 2, method_calls.count

        assert_nil method_calls.first.receiver
        assert_equal :bar, method_calls.first.method_name
        assert_equal [], method_calls.first.arguments

        assert_nil method_calls.last.receiver
        assert_equal :baz, method_calls.last.method_name
        assert_equal [], method_calls.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "assignment to variable" do
        expr = BetterHtml::TestHelper::RubyNode.parse('x = foo.bar')
        assert_equal 1, expr.return_values.count
        assert_equal s(:send, nil, :foo), expr.return_values.first.receiver
        assert_equal :bar, expr.return_values.first.method_name
        assert_equal [], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "assignment to variable with command call" do
        expr = BetterHtml::TestHelper::RubyNode.parse('raw x = foo.bar')
        assert_equal 1, expr.return_values.count
        assert_nil expr.return_values.first.receiver
        assert_equal :raw, expr.return_values.first.method_name
        assert_equal [s(:lvasgn, :x, s(:send, s(:send, nil, :foo), :bar))], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "assignment with instance call" do
        expr = BetterHtml::TestHelper::RubyNode.parse('(x = foo).bar')
        assert_equal 1, expr.return_values.count
        assert_equal s(:begin, s(:lvasgn, :x, s(:send, nil, :foo))), expr.return_values.first.receiver
        assert_equal :bar, expr.return_values.first.method_name
        assert_equal [], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "assignment to multiple variables" do
        expr = BetterHtml::TestHelper::RubyNode.parse('x, y = foo.bar')
        assert_equal 1, expr.return_values.count
        assert_equal s(:send, nil, :foo), expr.return_values.first.receiver
        assert_equal :bar, expr.return_values.first.method_name
        assert_equal [], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "safe navigation operator" do
        expr = BetterHtml::TestHelper::RubyNode.parse('foo&.bar')
        assert_equal 1, expr.return_values.count
        assert_equal s(:send, nil, :foo), expr.return_values.to_a[0].receiver
        assert_equal :bar, expr.return_values.to_a[0].method_name
        assert_equal [], expr.return_values.to_a[0].arguments
        refute_predicate expr, :static_return_value?
      end

      test "instance variable" do
        expr = BetterHtml::TestHelper::RubyNode.parse('@foo')
        assert_equal 0, expr.return_values.select(&:method_call?).count
        refute_predicate expr, :static_return_value?
      end

      test "instance method on variable" do
        expr = BetterHtml::TestHelper::RubyNode.parse('@foo.bar')
        assert_equal 1, expr.return_values.count
        assert_equal s(:ivar, :@foo), expr.return_values.first.receiver
        assert_equal :bar, expr.return_values.first.method_name
        assert_equal [], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "index into array" do
        expr = BetterHtml::TestHelper::RubyNode.parse('local_assigns[:text_class] if local_assigns[:text_class]')
        assert_equal 1, expr.return_values.count
        assert_equal s(:send, nil, :local_assigns), expr.return_values.first.receiver
        assert_equal :[], expr.return_values.first.method_name
        assert_equal [s(:sym, :text_class)], expr.return_values.first.arguments
        refute_predicate expr, :static_return_value?
      end

      test "static_return_value? for ivar" do
        expr = BetterHtml::TestHelper::RubyNode.parse('@foo')
        refute_predicate expr, :static_return_value?
      end

      test "static_return_value? for str" do
        expr = BetterHtml::TestHelper::RubyNode.parse("'str'")
        assert_predicate expr, :static_return_value?
      end

      test "static_return_value? for int" do
        expr = BetterHtml::TestHelper::RubyNode.parse("1")
        assert_predicate expr, :static_return_value?
      end

      test "static_return_value? for bool" do
        expr = BetterHtml::TestHelper::RubyNode.parse("true")
        assert_predicate expr, :static_return_value?
      end

      test "static_return_value? for nil" do
        expr = BetterHtml::TestHelper::RubyNode.parse("nil")
        assert_predicate expr, :static_return_value?
      end

      test "static_return_value? for dstr without interpolate" do
        expr = BetterHtml::TestHelper::RubyNode.parse('"str"')
        assert_predicate expr, :static_return_value?
      end

      test "static_return_value? for dstr with interpolate" do
        expr = BetterHtml::TestHelper::RubyNode.parse('"str #{foo}"')
        refute_predicate expr, :static_return_value?
      end

      test "static_return_value? with safe ternary" do
        expr = BetterHtml::TestHelper::RubyNode.parse('foo ? \'a\' : \'b\'')
        assert_predicate expr, :static_return_value?
      end

      test "static_return_value? with safe conditional" do
        expr = BetterHtml::TestHelper::RubyNode.parse('\'foo\' if bar?')
        assert_predicate expr, :static_return_value?
      end

      test "static_return_value? with safe assignment" do
        expr = BetterHtml::TestHelper::RubyNode.parse('x = \'foo\'')
        assert_predicate expr, :static_return_value?
      end
    end
  end
end
