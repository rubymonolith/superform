# frozen_string_literal: true

require "superform"
require "phlex"
require_relative "support/test_app"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Set up RSpec Rails view testing
  config.infer_spec_type_from_file_location!
end
