# -*- encoding: utf-8 -*-
# stub: google-protobuf 4.32.0 x86_64-linux-gnu lib

Gem::Specification.new do |s|
  s.name = "google-protobuf".freeze
  s.version = "4.32.0"
  s.platform = "x86_64-linux-gnu".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 3.3.22".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "source_code_uri" => "https://github.com/protocolbuffers/protobuf/tree/v4.32.0/ruby" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Protobuf Authors".freeze]
  s.date = "2025-08-14"
  s.description = "Protocol Buffers are Google's data interchange format.".freeze
  s.email = "protobuf@googlegroups.com".freeze
  s.homepage = "https://developers.google.com/protocol-buffers".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new([">= 3.1".freeze, "< 3.5.dev".freeze])
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Protocol Buffers".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<bigdecimal>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rake>.freeze, [">= 13"])
  s.add_development_dependency(%q<ffi>.freeze, ["~> 1"])
  s.add_development_dependency(%q<ffi-compiler>.freeze, ["~> 1"])
  s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 1.2"])
  s.add_development_dependency(%q<rake-compiler-dock>.freeze, ["~> 1.9"])
  s.add_development_dependency(%q<test-unit>.freeze, ["~> 3.0", ">= 3.0.9"])
end
