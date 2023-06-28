version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "aws-sessionstore-dynamodb"
  spec.version       = version
  spec.authors       = ["Amazon Web Services"]
  spec.email         = ["mamuller@amazon.com", "alexwoo@amazon.com"]

  spec.summary       = "The Amazon DynamoDB Session Store handles sessions " +
                       "for Ruby web applications using a DynamoDB backend."
  spec.homepage      = "http://github.com/aws/aws-sessionstore-dynamodb-ruby"
  spec.license       = "Apache License 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk-dynamodb', '~> 1'
  spec.add_dependency 'rack', '~> 2'
end
