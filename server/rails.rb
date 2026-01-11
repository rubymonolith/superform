# frozen_string_literal: true

require "bundler/setup"

require "active_model"
require "action_controller/railtie"
require "phlex-rails"

# Load superform from this repo
require_relative "../lib/superform"
require_relative "../lib/superform/rails"

# Directories
SERVER_DIR = File.expand_path(__dir__)
EXAMPLES_DIR = File.expand_path("../examples", __dir__)

# Load base class first (before Zeitwerk loads example forms)
require File.join(EXAMPLES_DIR, "example_form.rb")

# Load examples with Zeitwerk (no namespace, with reloading)
EXAMPLES_LOADER = Zeitwerk::Loader.new
EXAMPLES_LOADER.push_dir(EXAMPLES_DIR, namespace: Object)
EXAMPLES_LOADER.ignore(File.join(EXAMPLES_DIR, "example_form.rb"))
EXAMPLES_LOADER.enable_reloading
EXAMPLES_LOADER.setup

# Collect form classes dynamically (reloads on each request)
def form_classes
  EXAMPLES_LOADER.reload
  Dir[File.join(EXAMPLES_DIR, "*.rb")].sort.map do |file|
    class_name = File.basename(file, ".rb").split("_").map(&:capitalize).join
    Object.const_get(class_name)
  end
end

# Simple model for forms to bind to
class Example
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :password, :string
  attribute :age, :integer
  attribute :title, :string
  attribute :body, :string
  attribute :country, :string
  attribute :priority, :string
  attribute :quantity, :integer
  attribute :terms_accepted, :boolean
  attribute :subscribe, :boolean
  attribute :featured, :boolean
  attribute :birth_date, :date
  attribute :appointment_time, :time
  attribute :event_datetime, :datetime
  attribute :favorite_color, :string
  attribute :volume, :integer
  attribute :search_query, :string
  attribute :avatar, :string
  attribute :address, :string

  def self.model_name
    ActiveModel::Name.new(self, nil, "Example")
  end
end

# Layout component
class Layout < Phlex::HTML
  def initialize(title: "Superform Examples")
    @title = title
  end

  def view_template(&)
    doctype
    html do
      head do
        title { @title }
        link rel: "stylesheet", href: "/pico.min.css"
      end
      body do
        main class: "container" do
          header do
            h1 { a(href: "/") { "Superform Examples" } }
          end
          yield
        end
      end
    end
  end
end

# Index page
class IndexPage < Phlex::HTML
  def view_template
    render Layout.new do
      form_classes.each_with_index do |form_class, index|
        render FormCard.new(form_class: form_class, index: index)
      end
    end
  end
end

class FormCard < Phlex::HTML
  def initialize(form_class:, index:)
    @form_class = form_class
    @index = index
  end

  def view_template
    h2 { a(href: "/forms/#{@index}") { @form_class.name_text } }
    p { @form_class.description.html_safe }
  end
end

# Show page
class ShowPage < Phlex::HTML
  def initialize(form_class:)
    @form_class = form_class
    @form = form_class.new(Example.new, action: "#")
  end

  def view_template
    render Layout.new(title: "#{@form_class.name_text} - Superform Examples") do
      p { a(href: "/") { "Back to all forms" } }

      h2 { @form_class.name_text }
      p { @form_class.description.html_safe }
      render @form

      hr

      h3 { "Source Code" }
      pre do
        code { source_code }
      end
    end
  end

  private

  def source_code
    file = File.join(EXAMPLES_DIR, "#{underscore(@form_class.name)}.rb")
    File.exist?(file) ? File.read(file) : "# Source not found"
  end

  def underscore(name)
    name.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
  end
end

# Controller
class FormsController < ActionController::Base
  def index
    render IndexPage.new, layout: false
  end

  def show
    index = params[:id].to_i
    form_class = form_classes[index]
    render ShowPage.new(form_class: form_class), layout: false
  end
end

# Minimal Rails app
class SuperformApp < Rails::Application
  config.root = SERVER_DIR
  config.eager_load = false
  config.consider_all_requests_local = true
  config.secret_key_base = "superform-demo-secret-key-base-for-development-only"
  config.hosts.clear
  config.public_file_server.enabled = true
end

# Initialize and run
SuperformApp.initialize!

SuperformApp.routes.draw do
  root to: "forms#index"
  get "/forms/:id" => "forms#show", as: :form
end

def self.start(port: 3000)
  require "rackup"
  puts "Starting Superform Examples on http://localhost:#{port}"
  puts "Press Ctrl+C to stop"
  puts
  Rackup::Handler::WEBrick.run(SuperformApp, Port: port)
end
