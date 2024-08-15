$: << '.'
$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")


#require 'bundler/setup'
require 'oj'
require 'active_support'
require 'active_support/time_with_zone'
require 'tzinfo'

puts ActiveSupport::TimeWithZone

json = File.read('./bug.json')

Oj.load(json)
