# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require 'webdrivers/version'

Gem::Specification.new do |s|
  s.name        = 'webdrivers'
  s.version     = Webdrivers::VERSION
  s.authors     = ['Titus Fortner', 'Lakshya Kapoor', 'Thomas Walpole']
  s.email       = %w[titusfortner@gmail.com kapoorlakshya@gmail.com]
  s.homepage    = 'https://github.com/titusfortner/webdrivers'
  s.summary     = 'Easy download and use of browser drivers.'
  s.description = 'Run Selenium tests more easily with install and updates for all supported webdrivers.'
  s.licenses    = ['MIT']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'ffi', '~> 1.0' # For selenium-webdriver on Windows
  s.add_development_dependency 'irb'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'reline', '0.0.7' # Required by irb, and newer versions don't work on JRuby
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rubocop', '~>0.66'
  s.add_development_dependency 'rubocop-performance'
  s.add_development_dependency 'rubocop-rspec', '~>1.32'
  s.add_development_dependency 'simplecov', '~>0.16'

  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'rubyzip', '>= 1.3.0'
  s.add_runtime_dependency 'selenium-webdriver', '>= 3.0', '< 4.0'
end
