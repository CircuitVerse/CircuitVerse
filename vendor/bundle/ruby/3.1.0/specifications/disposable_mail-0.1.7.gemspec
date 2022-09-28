# -*- encoding: utf-8 -*-
# stub: disposable_mail 0.1.7 ruby lib

Gem::Specification.new do |s|
  s.name = "disposable_mail".freeze
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Oscar Esgalha".freeze]
  s.date = "2018-12-03"
  s.description = "DisposableMail serves you a blacklist with domains from disposable mail services, like mailinator.com or guerrillamail.com.\n The list can be used to prevent sending mails to these domains (which probably won't be open),\n or to prevent dummy users registration in your website.\n".freeze
  s.email = ["oscaresgalha@gmail.com".freeze]
  s.homepage = "https://github.com/oesgalha/disposable_mail".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "A ruby gem with a list of disposable mail domains.".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.6"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.6"])
  end
end
