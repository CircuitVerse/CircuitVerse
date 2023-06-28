# -*- encoding: utf-8 -*-
# stub: will_paginate-bootstrap 1.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "will_paginate-bootstrap".freeze
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nick Dainty".freeze]
  s.date = "2019-02-21"
  s.description = "This gem integrates the Twitter Bootstrap pagination component with the will_paginate pagination gem. Supports Rails and Sinatra.".freeze
  s.email = ["nick@npad.co.uk".freeze]
  s.homepage = "https://github.com/bootstrap-ruby/will_paginate-bootstrap".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Integrates the Twitter Bootstrap pagination component with will_paginate".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<will_paginate>.freeze, [">= 3.0.3"])
  else
    s.add_dependency(%q<will_paginate>.freeze, [">= 3.0.3"])
  end
end
