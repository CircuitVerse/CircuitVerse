Gem::Specification.new do |spec|
  spec.name          = "yosys2digitaljs"
  spec.version       = "0.1.0"
  spec.authors       = ["CircuitVerse"]
  spec.summary       = "Ruby compiler for Yosys to DigitalJS conversion"
  spec.files         = Dir["lib/**/*", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "json"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rake"
end
