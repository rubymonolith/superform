# frozen_string_literal: true

require "superform"

require 'action_view'
require 'active_model'
require 'phlex'
require 'phlex-rails'
require 'phlex/testing/nokogiri'
require 'phlex/testing/rails/view_helper'
require 'phlex/testing/view_helper'

require 'support/application_component'
require 'support/application_form'
require 'support/node_matcher'
require 'support/helpers'


RSpec.configure do |config|
  config.include Phlex::Testing::ViewHelper
  config.include Phlex::Testing::Rails::ViewHelper
  config.include Phlex::Testing::Nokogiri::FragmentHelper
  config.include Superform::Testing::Helpers

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
