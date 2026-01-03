# -*- encoding: utf-8 -*-
# stub: meta-tags 2.22.1 ruby lib

Gem::Specification.new do |s|
  s.name = "meta-tags".freeze
  s.version = "2.22.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/kpumuk/meta-tags/issues/", "changelog_uri" => "https://github.com/kpumuk/meta-tags/blob/main/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/github/kpumuk/meta-tags/", "homepage_uri" => "https://github.com/kpumuk/meta-tags/", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/kpumuk/meta-tags/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dmytro Shteflyuk".freeze]
  s.bindir = "exe".freeze
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDcDCCAligAwIBAgIBATANBgkqhkiG9w0BAQsFADA/MQ8wDQYDVQQDDAZrcHVt\ndWsxFjAUBgoJkiaJk/IsZAEZFgZrcHVtdWsxFDASBgoJkiaJk/IsZAEZFgRpbmZv\nMB4XDTI0MDcxNTIxMzIyNFoXDTI1MDcxNTIxMzIyNFowPzEPMA0GA1UEAwwGa3B1\nbXVrMRYwFAYKCZImiZPyLGQBGRYGa3B1bXVrMRQwEgYKCZImiZPyLGQBGRYEaW5m\nbzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALw2YroZc+IT+rs8NuPu\nc13DelrxrpAgPEu1zuRb3l7WaHRNWA4TyS8Z6Aa1G2O+FdUZNMW1n7IwP/QMJ9Mz\nahRBiTmhik5kasJ9s0h1lq5/hZiycm0o5OtGioUzCkvk+UEMpzMHbLmVSZCzYciy\nNDRDbXB0rLLu1eJk+gKgn6Qf5vj93h1w28BdWdaA7YegtbmipZ+pjmzCQAfPActT\n6uXHG4dSo7Lz9jiFRI5dUizFbGXcRqkQ2b5AB8FFmfcvbqERvzQKBICnybjsKP0N\npJ3vGgO2sh5GvJFOPk1Vlur2nX9ZFznPEP1CEAQ+NFrmKRt355Z5sgOkAojSGnIL\n/1sCAwEAAaN3MHUwCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0OBBYEFPa4\nVFc1YOlV1u/7EGTwMCAk8YE9MB0GA1UdEQQWMBSBEmtwdW11a0BrcHVtdWsuaW5m\nbzAdBgNVHRIEFjAUgRJrcHVtdWtAa3B1bXVrLmluZm8wDQYJKoZIhvcNAQELBQAD\nggEBADXj54X1y7Pw0Wp5wdniZE13a8EwWC41BEIsSoBLkGQhZ2OOR+5tVUM9kCwG\nkX6YdliORLuLevYXKiXFluiETwKTeAd6zUURy7eLlwQ1GvhE8wmGk0TQY11v8FMj\n7AupDtulpP01gLDZwbysovu/3btfhrLVncJ2zIpB5sx68fDCOmOGSUbdgOCV+S+O\nCyTFctYlJNXZgv2kl76TII7jbZikT/7hVOhCO48OdMQ/s26zabbJrcV2pJOLKKkP\nBKX4xDo6SbsGmqjFkknT6WiiE94rQxGCb9JNiSyl3SncEw+Ysx6yVKYB5WAEy8s1\nM0VQvDzd77bxj3lx/P6ifll3yUs=\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2024-09-20"
  s.description = "Search Engine Optimization (SEO) plugin for Ruby on Rails applications.".freeze
  s.email = ["kpumuk@kpumuk.info".freeze]
  s.homepage = "https://github.com/kpumuk/meta-tags".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Collection of SEO helpers for Ruby on Rails.".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 6.0.0", "< 8.1"])
  s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.5.0"])
  s.add_development_dependency(%q<railties>.freeze, [">= 3.2.0", "< 8.1"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.13.0"])
  s.add_development_dependency(%q<rspec-html-matchers>.freeze, ["~> 0.10.0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.22.0"])
  s.add_development_dependency(%q<rubocop-rails>.freeze, ["~> 2.26.0"])
  s.add_development_dependency(%q<rubocop-rake>.freeze, ["~> 0.6.0"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 3.0.1"])
  s.add_development_dependency(%q<standard>.freeze, ["~> 1.31"])
  s.add_development_dependency(%q<rspec_junit_formatter>.freeze, ["~> 0.6.0"])
end
