require_relative 'lib/ciphertext_sdk_test/version'

Gem::Specification.new do |spec|
  spec.name          = "ciphertext_sdk_test"
  spec.version       = CiphertextSdkTest::VERSION
  spec.authors       = ["Bennett Hardwick"]
  spec.email         = ["bennett@cipherstash.com"]

  spec.summary       = "Great summary"
  spec.description   = "Desc"
  spec.homepage      = "https://google.com"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://google.com"
  spec.metadata["changelog_uri"] = "https://google.com"

  spec.add_dependency 'rutie', '~> 0.0.3'

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rake", "~> 12.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
