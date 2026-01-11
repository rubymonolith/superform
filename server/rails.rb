# frozen_string_literal: true

require "bundler/setup"

require "active_model"
require "action_controller/railtie"
require "phlex-rails"

# Load superform from this repo
require_relative "../lib/superform"
require_relative "../lib/superform/rails"

# Directories
SERVER_DIR = Pathname.new(__dir__)
EXAMPLES_DIR = SERVER_DIR.join("../examples").expand_path

# Minimal Rails app
class SuperformApp < Rails::Application
  config.root = SERVER_DIR
  config.eager_load = false
  config.consider_all_requests_local = true
  config.secret_key_base = "superform-demo-secret-key-base-for-development-only"
  config.hosts.clear
  config.public_file_server.enabled = true

  config.autoload_paths << root.join("components")
  config.autoload_paths << root.join("models")
  config.autoload_paths << root.join("controllers")

  config.autoload_paths << EXAMPLES_DIR
end

# Collect form classes dynamically
def form_classes
  EXAMPLES_DIR.glob("*.rb").sort.filter_map do |path|
    next if path.basename.to_s == "example_form.rb"
    cpath = Rails.autoloaders.main.cpath_expected_at(path)
    Object.const_get(cpath)
  end
end

SuperformApp.initialize!

SuperformApp.routes.draw do
  root to: "forms#index"
  get "/forms/:id" => "forms#show", as: :form
  post "/forms/:id" => "forms#create"
end

def self.start(port: 3000)
  require "rackup"
  puts "Starting Superform Examples on http://localhost:#{port}"
  puts "Press Ctrl+C to stop"
  puts
  Rackup::Handler::WEBrick.run(SuperformApp, Port: port)
end
