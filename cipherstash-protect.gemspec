require_relative './lib/cipherstash/protect/version'

Gem::Specification.new do |spec|
  spec.name          = "cipherstash-protect"
  spec.version       = CipherStash::Protect::VERSION
  spec.authors       = ["Fi McCawley", "James Sadler"]
  spec.email         = ["fiona@cipherstash.com", "james@cipherstash.com", "robin@cipherstash.com"]

  spec.summary       = %q{Add searchable encryption to your rails models}
  spec.description   = %q{This gem wraps the CipherStash order-revealing-encryption library and enhances ActiveRecord to support encrypted search}
  spec.homepage      = "https://cipherstash.com/protect"
  spec.license       = "LicenseRef-LICENCE"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/cipherstash/protect"
  spec.metadata["changelog_uri"] = "https://github.com/cipherstash/protect/releases"
  spec.metadata["bug_tracker_uri"] = "https://github.com/cipherstash/protect/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/protect"
  spec.metadata["mailing_list_uri"] = "https://discuss.cipherstash.com"

  spec.add_runtime_dependency "activerecord"
  spec.add_runtime_dependency "lockbox"
  spec.add_runtime_dependency "ore-rs", "~> 0.7.0"
  spec.add_runtime_dependency "progress_bar"
  spec.add_runtime_dependency "uuid"
  spec.add_runtime_dependency "hkdf", "~>1.0"

  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency "debug", ">= 1.0.0"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 11.2"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "database_cleaner"


  spec.files = Dir["README.md", "lib/**/*"]
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
