# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "active_record/railtie"
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

# Set up in-memory SQLite database for ActiveRecord
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new("/dev/null")

# Define minimal schema
ActiveRecord::Schema.define(version: 1) do
  create_table :users, force: true do |t|
    t.string :first_name
    t.string :last_name
    t.string :email
    t.timestamps
  end
end

# User ActiveRecord model for testing
class User < ActiveRecord::Base
  validates :first_name, presence: true
  validates :email, presence: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
end

# Minimal controller for URL generation
class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers

  def default_url_options
    { host: 'test.host' }
  end
end

# Controller for exercising StrongParameters via real requests
class UsersController < ApplicationController
  include Superform::Rails::StrongParameters

  # Standard RESTful actions to exercise Superform with url_for
  def create
    @user = User.new
    if save Users::Form.new(@user)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])
    save! Users::Form.new(@user)
    head :ok
  end
end

# Set up routes for URL helpers
Rails.application.routes.draw do
  resources :users, only: [:create, :update]
  root 'users#index'
end
