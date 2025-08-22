# frozen_string_literal: true

require "phlex"

module Superform
  # A basic form component that inherits from Phlex::HTML and wraps content in a form tag.
  # This provides a simple foundation for building forms without Rails dependencies.
  #
  # Example usage:
  #   class MyForm < Superform::Form
  #     def view_template
  #       div { "Form content goes here" }
  #     end
  #   end
  #
  #   form = MyForm.new(action: "/users", method: :post)
  #   form.call # renders <form action="/users" method="post">...</form>
  class Form < Phlex::HTML
    def initialize(action: nil, method: :post, **attributes)
      @action = action
      @method = method
      @attributes = attributes
      super()
    end

    def around_template(&block)
      form(action: @action, method: @method, **@attributes, &block)
    end

    def build_field(key, parent:, object: nil, &block)
      Field.new(key, parent: parent, object: object, &block)
    end
  end
end
