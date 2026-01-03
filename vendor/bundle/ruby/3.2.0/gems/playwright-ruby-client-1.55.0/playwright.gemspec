# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'playwright/version'

Gem::Specification.new do |spec|
  spec.name          = 'playwright-ruby-client'
  spec.version       = Playwright::VERSION

  spec.authors       = ['YusukeIwaki']
  spec.email         = ['q7w8e9w8q7w8e9@yahoo.co.jp']

  spec.summary       = "The Ruby binding of playwright driver #{Playwright::COMPATIBLE_PLAYWRIGHT_VERSION}"
  spec.homepage      = 'https://github.com/YusukeIwaki/playwright-ruby-client'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/}) || f.include?(".git") || f.include?(".circleci") || f.start_with?("development/")
    end
  end + `find lib/playwright_api -name *.rb -type f`.split("\n") + `find sig -name *.rbs -type f`.split("\n")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'
  spec.add_dependency 'concurrent-ruby', '>= 1.1.6'
  spec.add_dependency 'mime-types', '>= 3.0'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'chunky_png'
  spec.add_development_dependency 'dry-inflector'
  spec.add_development_dependency 'faye-websocket'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'puma'
  spec.add_development_dependency 'rack', '< 3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'sinatra'
end
