# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'language_filter/version'

Gem::Specification.new do |spec|
  spec.name          = "language_filter"
  spec.version       = LanguageFilter::VERSION
  spec.authors       = ["Chris Fritz"]
  spec.email         = ["chrisvfritz@gmail.com"]
  spec.description   = %q{LanguageFilter is a Ruby gem to detect and optionally filter various categories of language.}
  spec.summary       = %q{LanguageFilter is a Ruby gem to detect and optionally filter various categories of language.}
  spec.homepage      = "http://github.com/chrisvfritz/language_filter"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
