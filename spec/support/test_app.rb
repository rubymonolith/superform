# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "active_model"
require "rspec/rails"

# Minimal Rails application for testing
class TestApp < Rails::Application
  config.eager_load = false
  config.session_store :cookie_store, key: '_test_session'
  config.secret_key_base = 'test_secret'
  config.logger = Logger.new('/dev/null')
  config.active_support.deprecation = :log
  config.action_view.finalize_compiled_template_methods = false
end

# Initialize the Rails app
TestApp.initialize! unless Rails.application

# Minimal controller for URL generation
class ApplicationController < ActionController::Base
  def self.default_url_options
    { host: 'test.host' }
  end
end

# Set up routes for URL helpers
Rails.application.routes.draw do
  resources :users
  root 'users#index'
end

# User ActiveModel for testing
class User
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment

  attribute :name, :string
  attribute :email, :string
  attribute :id, :integer

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def persisted?
    id.present?
  end
end
