# -*- encoding: utf-8 -*-
# stub: fast_jsonapi 1.5 ruby lib

Gem::Specification.new do |s|
  s.name = "fast_jsonapi".freeze
  s.version = "1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Shishir Kakaraddi".freeze, "Srinivas Raghunathan".freeze, "Adam Gross".freeze]
  s.date = "2018-11-03"
  s.description = "JSON API(jsonapi.org) serializer that works with rails and can be used to serialize any kind of ruby objects".freeze
  s.email = "".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.homepage = "http://github.com/Netflix/fast_jsonapi".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "fast JSON API(jsonapi.org) serializer".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.2"])
      s.add_development_dependency(%q<activerecord>.freeze, [">= 4.2"])
      s.add_development_dependency(%q<skylight>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
      s.add_development_dependency(%q<oj>.freeze, ["~> 3.3"])
      s.add_development_dependency(%q<rspec-benchmark>.freeze, ["~> 0.3.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_development_dependency(%q<active_model_serializers>.freeze, ["~> 0.10.7"])
      s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<jsonapi-rb>.freeze, ["~> 0.5.0"])
      s.add_development_dependency(%q<jsonapi-serializers>.freeze, ["~> 1.0.0"])
    else
      s.add_dependency(%q<activesupport>.freeze, [">= 4.2"])
      s.add_dependency(%q<activerecord>.freeze, [">= 4.2"])
      s.add_dependency(%q<skylight>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
      s.add_dependency(%q<oj>.freeze, ["~> 3.3"])
      s.add_dependency(%q<rspec-benchmark>.freeze, ["~> 0.3.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_dependency(%q<active_model_serializers>.freeze, ["~> 0.10.7"])
      s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3"])
      s.add_dependency(%q<jsonapi-rb>.freeze, ["~> 0.5.0"])
      s.add_dependency(%q<jsonapi-serializers>.freeze, ["~> 1.0.0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 4.2"])
    s.add_dependency(%q<activerecord>.freeze, [">= 4.2"])
    s.add_dependency(%q<skylight>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
    s.add_dependency(%q<oj>.freeze, ["~> 3.3"])
    s.add_dependency(%q<rspec-benchmark>.freeze, ["~> 0.3.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_dependency(%q<active_model_serializers>.freeze, ["~> 0.10.7"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3"])
    s.add_dependency(%q<jsonapi-rb>.freeze, ["~> 0.5.0"])
    s.add_dependency(%q<jsonapi-serializers>.freeze, ["~> 1.0.0"])
  end
end
