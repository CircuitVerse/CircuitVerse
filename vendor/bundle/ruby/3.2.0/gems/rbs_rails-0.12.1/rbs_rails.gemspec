require_relative 'lib/rbs_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "rbs_rails"
  spec.version       = RbsRails::VERSION
  spec.authors       = ["Masataka Pocke Kuwabara"]
  spec.email         = ["kuwabara@pocke.me"]

  spec.summary       = %q{A RBS files generator for Rails application}
  spec.description   = %q{A RBS files generator for Rails application}
  spec.homepage      = "https://github.com/pocke/rbs_rails"
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = Gem::Requirement.new(">= 3.2")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/pocke/rbs_rails/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'parser'
  spec.add_runtime_dependency 'rbs', '>= 1'
end
