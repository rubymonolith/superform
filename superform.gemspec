# frozen_string_literal: true

require_relative "lib/superform/version"

Gem::Specification.new do |spec|
  spec.name = "superform"
  spec.version = Superform::VERSION
  spec.authors = ["Brad Gessler"]
  spec.email = ["bradgessler@gmail.com"]

  spec.summary = "Build forms in Rails"
  spec.description = "A better way to customize and build forms for your Rails application"
  spec.homepage = "https://github.com/rubymonolith/superform"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rubymonolith/superform"
  spec.metadata["changelog_uri"] = "https://github.com/rubymonolith/superform"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # 2.0 rcs, betas, etc.
  spec.add_dependency "phlex-rails", "~> 2.0"
  spec.add_dependency "zeitwerk", "~> 2.6"
end
