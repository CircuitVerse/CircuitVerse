# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack/pjax/version"

Gem::Specification.new do |s|
  s.name        = "rack-pjax"
  s.version     = Rack::Pjax::VERSION
  s.authors     = ["Gert Goet"]
  s.email       = ["gert@thinkcreate.nl"]
  s.homepage    = "https://github.com/eval/rack-pjax"
  s.license     = "MIT"
  s.summary     = %q{Serve pjax responses through rack middleware}
  s.description = %q{Serve pjax responses through rack middleware}

  s.rubyforge_project = "rack-pjax"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rack', '>= 1.1')
  s.add_dependency('nokogiri', '~> 1.5')

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rack-test"
end
