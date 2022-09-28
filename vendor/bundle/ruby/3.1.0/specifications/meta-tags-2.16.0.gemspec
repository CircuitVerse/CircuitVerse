# -*- encoding: utf-8 -*-
# stub: meta-tags 2.16.0 ruby lib

Gem::Specification.new do |s|
  s.name = "meta-tags".freeze
  s.version = "2.16.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/kpumuk/meta-tags/issues/", "changelog_uri" => "https://github.com/kpumuk/meta-tags/blob/main/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/github/kpumuk/meta-tags/", "homepage_uri" => "https://github.com/kpumuk/meta-tags/", "source_code_uri" => "https://github.com/kpumuk/meta-tags/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dmytro Shteflyuk".freeze]
  s.bindir = "exe".freeze
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDODCCAiCgAwIBAgIBATANBgkqhkiG9w0BAQsFADAjMSEwHwYDVQQDDBhrcHVt\ndWsvREM9a3B1bXVrL0RDPWluZm8wHhcNMjAxMjEwMjA1MTE5WhcNMjExMjEwMjA1\nMTE5WjAjMSEwHwYDVQQDDBhrcHVtdWsvREM9a3B1bXVrL0RDPWluZm8wggEiMA0G\nCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC8NmK6GXPiE/q7PDbj7nNdw3pa8a6Q\nIDxLtc7kW95e1mh0TVgOE8kvGegGtRtjvhXVGTTFtZ+yMD/0DCfTM2oUQYk5oYpO\nZGrCfbNIdZauf4WYsnJtKOTrRoqFMwpL5PlBDKczB2y5lUmQs2HIsjQ0Q21wdKyy\n7tXiZPoCoJ+kH+b4/d4dcNvAXVnWgO2HoLW5oqWfqY5swkAHzwHLU+rlxxuHUqOy\n8/Y4hUSOXVIsxWxl3EapENm+QAfBRZn3L26hEb80CgSAp8m47Cj9DaSd7xoDtrIe\nRryRTj5NVZbq9p1/WRc5zxD9QhAEPjRa5ikbd+eWebIDpAKI0hpyC/9bAgMBAAGj\ndzB1MAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdDgQWBBT2uFRXNWDpVdbv\n+xBk8DAgJPGBPTAdBgNVHREEFjAUgRJrcHVtdWtAa3B1bXVrLmluZm8wHQYDVR0S\nBBYwFIESa3B1bXVrQGtwdW11ay5pbmZvMA0GCSqGSIb3DQEBCwUAA4IBAQBdcrpl\n32OlNaf68v38yzqYkviLELtbzRvEpRuQWZZyxOwU1OWSFAWkkALuseLWHDLYRDE8\nlOzQHewKodqaSPEo63vMZ28UQ3kDP1YE+cXR12fOg4YbCH8VETrTJa3X0AOOAbgA\nZLMcZD6wu9Zu2rPhxLxs6Q/PaGGEc8bonOirCZrwVDzHFA1cPjcSoApdsyGdRiyj\n1f+XHXjCE5A1A6b8o4ffpAI6gkuaQOIrgGCyLS9oos6DSuofkvXI9g62G+2ZOmKJ\nU97JEQmXCpruLEeSVT2UqR+iJAWEAxPzqzDbTzZBTSPKn+nXeuF6h81e4hsJtkeJ\nHkYAoatF9iZrxT4E\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2021-09-23"
  s.description = "Search Engine Optimization (SEO) plugin for Ruby on Rails applications.".freeze
  s.email = ["kpumuk@kpumuk.info".freeze]
  s.homepage = "https://github.com/kpumuk/meta-tags".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Collection of SEO helpers for Ruby on Rails.".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<actionpack>.freeze, [">= 3.2.0", "< 7.1"])
    s.add_development_dependency(%q<railties>.freeze, [">= 3.2.0", "< 7.1"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.10.0"])
    s.add_development_dependency(%q<rspec-html-matchers>.freeze, ["~> 0.9.1"])
  else
    s.add_dependency(%q<actionpack>.freeze, [">= 3.2.0", "< 7.1"])
    s.add_dependency(%q<railties>.freeze, [">= 3.2.0", "< 7.1"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.10.0"])
    s.add_dependency(%q<rspec-html-matchers>.freeze, ["~> 0.9.1"])
  end
end
