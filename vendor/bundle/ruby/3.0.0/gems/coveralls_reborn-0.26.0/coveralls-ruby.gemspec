# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'coveralls/version'

Gem::Specification.new do |gem|
  gem.authors       = ['Nick Merwin', 'Wil Gieseler', 'Geremia Taglialatela']
  gem.email         = ['nick@lemurheavy.com', 'supapuerco@gmail.com', 'tagliala.dev@gmail.com']
  gem.description   = 'A Ruby implementation of the Coveralls API.'
  gem.summary       = 'A Ruby implementation of the Coveralls API.'
  gem.homepage      = 'https://coveralls.io'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.name          = 'coveralls_reborn'
  gem.require_paths = ['lib']
  gem.version       = Coveralls::VERSION

  gem.metadata['rubygems_mfa_required'] = 'true'

  gem.metadata['bug_tracker_uri'] = 'https://github.com/tagliala/coveralls-ruby-reborn/issues'
  gem.metadata['changelog_uri'] = 'https://github.com/tagliala/coveralls-ruby-reborn/blob/main/CHANGELOG.md'
  gem.metadata['source_code_uri'] = 'https://github.com/tagliala/coveralls-ruby-reborn'

  gem.required_ruby_version = '>= 2.6'

  gem.add_dependency 'simplecov', '~> 0.22.0'
  gem.add_dependency 'term-ansicolor', '~> 1.7'
  gem.add_dependency 'thor', '~> 1.2'
  gem.add_dependency 'tins', '~> 1.32'

  gem.add_development_dependency 'bundler', '~> 2.0'
  gem.add_development_dependency 'simplecov-lcov', '~> 0.8.0'
end
