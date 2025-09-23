# frozen_string_literal: true

require "test_helper"

class SymbolizeKeysTest < Minitest::Test
  test "symbolizes hash" do
    input = {"a" => {"b" => 1}, 42 => "the answer"}
    expected = {a: {b: 1}, "42": "the answer"}
    actual = Glob::SymbolizeKeys.call(input)

    assert_equal expected, actual
  end

  test "symbolizes arrays" do
    input = [{"a" => {"b" => [1, 2, 3]}}]
    expected = [{a: {b: [1, 2, 3]}}]
    actual = Glob::SymbolizeKeys.call(input)

    assert_equal expected, actual
  end
end
