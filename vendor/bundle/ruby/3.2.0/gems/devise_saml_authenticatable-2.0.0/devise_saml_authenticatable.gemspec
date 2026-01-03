# -*- encoding: utf-8 -*-
require File.expand_path('../lib/devise_saml_authenticatable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Josef Sauter"]
  gem.email         = ["Josef.Sauter@gmail.com"]
  gem.description   = %q{SAML Authentication for devise}
  gem.summary       = %q{SAML Authentication for devise }
  gem.homepage      = "https://github.com/apokalipto/devise_saml_authenticatable"
  gem.license     = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "devise_saml_authenticatable"
  gem.require_paths = ["lib"]
  gem.version       = DeviseSamlAuthenticatable::VERSION
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.required_ruby_version = ">= 2.6.0"

  gem.add_dependency("devise","> 2.0.0")
  gem.add_dependency("ruby-saml","~> 1.18")
end
