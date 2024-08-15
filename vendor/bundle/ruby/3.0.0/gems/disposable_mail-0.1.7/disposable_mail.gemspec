# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'disposable_mail/version'

Gem::Specification.new do |spec|
  spec.name          = 'disposable_mail'
  spec.version       = DisposableMail::VERSION
  spec.authors       = ['Oscar Esgalha']
  spec.email         = ['oscaresgalha@gmail.com']
  spec.summary       = %q{A ruby gem with a list of disposable mail domains.}
  spec.description   = <<DESC
DisposableMail serves you a blacklist with domains from disposable mail services, like mailinator.com or guerrillamail.com.
 The list can be used to prevent sending mails to these domains (which probably won't be open),
 or to prevent dummy users registration in your website.
DESC
  spec.homepage      = 'https://github.com/oesgalha/disposable_mail'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.6'
end
