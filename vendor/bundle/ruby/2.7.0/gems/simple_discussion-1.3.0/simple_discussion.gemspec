lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "simple_discussion/version"

Gem::Specification.new do |spec|
  spec.name = "simple_discussion"
  spec.version = SimpleDiscussion::VERSION
  spec.authors = ["Chris Oliver"]
  spec.email = ["excid3@gmail.com"]

  spec.summary = "A simple, extensible Rails forum"
  spec.description = "A simple, extensible Rails forum"
  spec.homepage = "https://github.com/excid3/simple_discussion"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "font-awesome-sass", ">= 5.13.0"
  spec.add_dependency "friendly_id", ">= 5.2.0"
  spec.add_dependency "rails", ">= 4.2"
  spec.add_dependency "will_paginate", ">= 3.1.0"
end
