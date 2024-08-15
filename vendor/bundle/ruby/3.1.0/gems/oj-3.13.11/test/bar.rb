#!/usr/bin/env ruby

$: << '.'
$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")

require 'oj'

json = %|[{"x12345678901234567890": true}]|

p = Oj::Parser.new(:usual)
p.cache_keys = false
p.symbol_keys = true
x = p.parse(json)

pp x
