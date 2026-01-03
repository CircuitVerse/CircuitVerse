# -*- encoding: utf-8 -*-
# stub: vite_ruby 3.9.2 ruby lib

Gem::Specification.new do |s|
  s.name = "vite_ruby".freeze
  s.version = "3.9.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/ElMassimo/vite_ruby/blob/vite_ruby@3.9.2/vite_ruby/CHANGELOG.md", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/ElMassimo/vite_ruby/tree/vite_ruby@3.9.2/vite_ruby" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["M\u00E1ximo Mussini".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-03-26"
  s.email = ["maximomussini@gmail.com".freeze]
  s.executables = ["vite".freeze]
  s.files = ["exe/vite".freeze]
  s.homepage = "https://github.com/ElMassimo/vite_ruby".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "Thanks for installing Vite Ruby!\n\nIf you upgraded the gem manually, please run:\n\tbundle exec vite upgrade".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Use Vite in Ruby and bring joy to your JavaScript experience".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<dry-cli>.freeze, [">= 0.7", "< 2"])
  s.add_runtime_dependency(%q<logger>.freeze, ["~> 1.6"])
  s.add_runtime_dependency(%q<mutex_m>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rack-proxy>.freeze, ["~> 0.6", ">= 0.6.1"])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.2"])
  s.add_development_dependency(%q<m>.freeze, ["~> 1.5"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
  s.add_development_dependency(%q<minitest-reporters>.freeze, ["~> 1.4"])
  s.add_development_dependency(%q<minitest-stub_any_instance>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<pry-byebug>.freeze, ["~> 3.9"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["< 0.23"])
end
