module Components
  class Form < Superform::Rails::Form
    # Extend the Field class to add your own custom helpers.
    class Field < self::Field
      # # Overide base form helpers for small modifications, like injecting
      # # default classes or styles.
      # def input(class: nil, **)
      #   super(class: ["border p-2", grab(class:)], **)
      # end
      #
      # # Create custom field helpers that may be accessed via `fied(:email).my_input`
      # def required_email(**)
      #   input(type: "email", required: true, **)
      # end
      #
      # # Return your own component if you're doing more complicated things.
      # def autocomplete(**attributes)
      #   Components::Autocomplete.new(field, attributes:)
      # end
    end

    def around_template(&)
      super do
        # Renders error messages if there are any validation errors on the model
        error_messages
        # Renders the contents of the form from `view_template` or the block passed
        # the #render method.
        yield if block_given?
        # Renders the submit button for the form.
        submit
      end
    end

    # This is needed for the `error_messages`
    include Phlex::Rails::Helpers::Pluralize

    # Displays error messages for the form's model if there are any validation errors.
    def error_messages
      if model.errors.any?
        div(style: "color: red;") do
          h2 { "#{pluralize model.errors.count, "error"} prohibited this post from being saved:" }
          ul do
            model.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end
    end

    # Wraps a form field and its label in a div for layout purposes.
    def row(component)
      div do
        render component.field.label(style: "display: block;")
        render component
      end
    end
  end
end
