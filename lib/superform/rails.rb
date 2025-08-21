require "phlex/rails"

module Superform
  module Rails
    # When this is included in a Rails app, check if `Components::Base` is defined and
    # inherit from that so we get all the users stuff; otherwise inherit from Phlex::HTML,
    # which means we won't have all the users methods and overrides.
    SUPERCLASSES = [
      "::Components::Base",       # Phlex 2.x base class in a Rails project
      "::ApplicationComponent",   # Phlex 1.x base class in a Rails project
      "::Phlex::HTML",            # Couldn't detect a base Phlex Rails class, so use Phlex::HTML
    ]

    # Find the base class for the Rails app.
    def self.base_class
      const_get SUPERCLASSES.find { |const| const_defined?(const) }
    end

    # Set the base class for the rem
    Component = base_class
  end
end