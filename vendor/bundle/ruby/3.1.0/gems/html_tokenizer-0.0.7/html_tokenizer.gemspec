Gem::Specification.new do |spec|
  spec.name    = "html_tokenizer"
  spec.version = "0.0.7"
  spec.summary = "HTML Tokenizer"
  spec.author  = "Francois Chagnon"

  spec.files = Dir.glob("ext/**/*.{c,h,rb}") +
            Dir.glob("lib/**/*.rb")

  spec.extensions    = ['ext/html_tokenizer_ext/extconf.rb']
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "ext"]

  spec.add_development_dependency 'rake', '~> 0'
  spec.add_development_dependency 'rake-compiler', '~> 0'
  spec.add_development_dependency 'minitest', '~> 0'
end
