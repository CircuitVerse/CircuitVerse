# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'undercover/version'

Gem::Specification.new do |spec|
  spec.name          = 'undercover'
  spec.version       = Undercover::VERSION
  spec.authors       = ['Jan Grodowski']
  spec.email         = ['jgrodowski@gmail.com']

  spec.summary       = 'Actionable code coverage - detects untested ' \
                       'code blocks in recent changes'
  spec.homepage      = 'https://github.com/grodowski/undercover'
  spec.license       = 'MIT'
  spec.metadata      = {
    'rubygems_mfa_required' => 'true'
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(/^(test|spec|features)\//)
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_dependency 'base64'
  spec.add_dependency 'bigdecimal'
  spec.add_dependency 'imagen', '>= 0.2.0'
  spec.add_dependency 'rainbow', '>= 2.1', '< 4.0'
  spec.add_dependency 'rugged', '>= 0.27', '< 1.10'
  spec.add_dependency 'simplecov'
  spec.add_dependency 'simplecov_json_formatter'
end
