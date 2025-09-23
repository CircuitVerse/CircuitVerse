# frozen_string_literal: true

# rubocop:disable all
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'imagen/version'

Gem::Specification.new do |spec|
  spec.name          = 'imagen'
  spec.version       = Imagen::VERSION
  spec.authors       = ['Jan Grodowski']
  spec.email         = ['jgrodowski@gmail.com']

  spec.summary       = %q{Codebase as structure of locatable classes and methods based on the Ruby AST}
  spec.homepage      = "https://github.com/grodowski/imagen_rb"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'parser', '>= 2.5', '!= 2.5.1.1'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-lcov'
  spec.add_development_dependency 'simplecov-html'
end
# rubocop:enable all
