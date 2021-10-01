#!/usr/bin/env ruby

$: << File.dirname(__FILE__)
$oj_dir = File.dirname(File.expand_path(File.dirname(__FILE__)))
%w(lib ext).each do |dir|
  $: << File.join($oj_dir, dir)
end

require 'oj'

p = Oj::Parser.new(:debug)

p.parse("[true, false]")
