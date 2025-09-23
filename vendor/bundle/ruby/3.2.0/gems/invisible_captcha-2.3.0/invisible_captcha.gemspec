require './lib/invisible_captcha/version'

Gem::Specification.new do |spec|
  spec.name          = "invisible_captcha"
  spec.version       = InvisibleCaptcha::VERSION
  spec.authors       = ["Marc Anguera Insa"]
  spec.email         = ["srmarc.ai@gmail.com"]
  spec.description   = "Unobtrusive, flexible and complete spam protection for Rails applications using honeypot strategy for better user experience."
  spec.summary       = "Honeypot spam protection for Rails"
  spec.homepage      = "https://github.com/markets/invisible_captcha"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', '>= 5.2'

  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'webrick'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-cobertura'
end
