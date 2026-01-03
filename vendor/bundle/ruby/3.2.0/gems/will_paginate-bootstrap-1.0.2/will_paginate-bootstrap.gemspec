# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bootstrap_pagination/version"

Gem::Specification.new do |s|
  s.name        = "will_paginate-bootstrap"
  s.version     = BootstrapPagination::VERSION
  s.authors     = ["Nick Dainty"]
  s.email       = ["nick@npad.co.uk"]
  s.homepage    = "https://github.com/bootstrap-ruby/will_paginate-bootstrap"
  s.summary     = %q{Integrates the Twitter Bootstrap pagination component with will_paginate}
  s.description = %q{This gem integrates the Twitter Bootstrap pagination component with the will_paginate pagination gem. Supports Rails and Sinatra.}
  s.license     = "MIT"

  s.rubyforge_project = "will_paginate-bootstrap"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "will_paginate", ">= 3.0.3"
end
