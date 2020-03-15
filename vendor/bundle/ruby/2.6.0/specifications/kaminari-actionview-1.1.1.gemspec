# -*- encoding: utf-8 -*-
# stub: kaminari-actionview 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "kaminari-actionview".freeze
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Akira Matsuda".freeze]
  s.date = "2017-10-21"
  s.description = "kaminari-actionview provides pagination helpers for your Action View templates".freeze
  s.email = ["ronnie@dio.jp".freeze]
  s.homepage = "https://github.com/kaminari/kaminari".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Kaminari Action View adapter".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<kaminari-core>.freeze, ["= 1.1.1"])
      s.add_runtime_dependency(%q<actionview>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 1.12"])
      s.add_development_dependency(%q<rake>.freeze, [">= 10.0"])
    else
      s.add_dependency(%q<kaminari-core>.freeze, ["= 1.1.1"])
      s.add_dependency(%q<actionview>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 1.12"])
      s.add_dependency(%q<rake>.freeze, [">= 10.0"])
    end
  else
    s.add_dependency(%q<kaminari-core>.freeze, ["= 1.1.1"])
    s.add_dependency(%q<actionview>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.12"])
    s.add_dependency(%q<rake>.freeze, [">= 10.0"])
  end
end
