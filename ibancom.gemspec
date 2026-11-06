# frozen_string_literal: true

require_relative "lib/ibancom/version"

Gem::Specification.new do |spec|
  spec.name = "ibancom"
  spec.version = Ibancom::VERSION
  spec.authors = ["Aitor García Rey"]
  spec.email = ["dev@devengo.com"]

  spec.summary = "Ruby client for iban.com APIs"
  spec.description = "Ruby client for iban.com APIs"
  spec.homepage = "https://github.com/devengoapp/ibancom-ruby"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/devengoapp/ibancom-ruby"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.2"
  spec.add_dependency "faraday", ">= 2.14.3", "< 3"
end
