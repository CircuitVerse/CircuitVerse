# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-gitlab/version'

Gem::Specification.new do |gem|
  gem.name          = 'omniauth-gitlab'
  gem.version       = Omniauth::Gitlab::VERSION
  gem.authors       = ['Sergey Sein']
  gem.email         = ['linchus@gmail.com']
  gem.description   = 'This is the strategy for authenticating to your GitLab service'
  gem.summary       = 'This is the strategy for authenticating to your GitLab service'
  gem.homepage      = 'https://github.com/linchus/omniauth-gitlab'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'omniauth', '~> 2.0'
  gem.add_dependency 'omniauth-oauth2', '~> 1.8.0'
  gem.add_development_dependency 'rspec', '~> 3.1'
  gem.add_development_dependency 'rspec-its', '~> 1.0'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rake', '>= 12.0'
end
