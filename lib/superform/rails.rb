module Superform
  module Rails
    # A Phlex::HTML view that accepts a model and sets a `Superform::Namespace`
    # with the `Object#model_name` as the key and maps the object to form fields
    # and namespaces.
    #
    # The `Form::Field` class is designed to be extended so you can customize the `Form` inputs
    # to your applications needs. Defaults for the `input`, `button`, `label`, and `textarea` tags
    # are provided.
    #
    # The `Form` component also handles Rails authenticity tokens via the `authenticity_toklen_field`
    # method and the HTTP verb via the `_method_field`.
    class Form < Phlex::HTML
      attr_reader :model

      delegate \
          :field,
          :collection,
          :namespace,
          :key,
          :assign,
          :serialize,
        to: :@namespace

      # The Field class is designed to be extended to create custom forms. To override,
      # in your subclass you may have something like this:
      #
      # ```ruby
      # class MyForm
      #   class MyLabel < FieldComponent
      #     def template(&content)
      #       label(form: @field.dom.name, class: "text-bold", &content)
      #     end
      #   end
      #
      #   class Field < Field
      #     def label(**attributes)
      #       MyLabel.new(self, attributes: **attributes)
      #     end
      #   end
      # end
      # ```
      #
      # Now all calls to `label` will have the `text-bold` class applied to it.
      class Field < Superform::Field
        def button(**attributes)
          Components::ButtonComponent.new(self, attributes: attributes)
        end

        def input(**attributes)
          Components::InputComponent.new(self, attributes: attributes)
        end

        def label(**attributes)
          Components::LabelComponent.new(self, attributes: attributes)
        end

        def select(**attributes)
          Components::CollectionSelect.new(self, attributes: attributes)
        end

        def textarea(**attributes)
          Components::TextareaComponent.new(self, attributes: attributes)
        end

        def title
          key.to_s.titleize
        end
      end

      def initialize(model, action: nil, method: nil)
        @model = model
        @action = action
        @method = method
        @namespace = Namespace.root(model.model_name.param_key, object: model, field_class: self.class::Field)
      end

      def around_template(&)
        form_tag do
          authenticity_token_field
          _method_field
          super
        end
      end

      def form_tag(&)
        form action: form_action, method: form_method, &
      end

      def template(&block)
        yield_content(&block)
      end

      def submit(value = submit_value, **attributes)
        input **attributes.merge(
          name: "commit",
          type: "submit",
          value: value
        )
      end

      protected

      def authenticity_token_field
        input(
          name: "authenticity_token",
          type: "hidden",
          value: helpers.form_authenticity_token
        )
      end

      def _method_field
        input(
          name: "_method",
          type: "hidden",
          value: _method_field_value
        )
      end

      def _method_field_value
        @method || @model.persisted? ? "patch" : "post"
      end

      def submit_value
        "#{resource_action.to_s.capitalize} #{@model.model_name}"
      end

      def resource_action
        @model.persisted? ? :update : :create
      end

      def form_action
        @action ||= helpers.url_for(action: resource_action)
      end

      def form_method
        @method.to_s.downcase == "get" ? "get" : "post"
      end
    end

    module StrongParameters
      protected
        # Assigns params to the form and returns the model.
        def assign(params, to:)
          form = to
          # TODO: Figure out how to render this in a way that doesn't concat a string; just throw everything away.
          render_to_string form
          form.assign params
          form.model
        end
    end

    module Components
      class FieldComponent < ApplicationComponent
        attr_reader :field, :dom

        delegate :dom, to: :field

        def initialize(field, attributes: {})
          @field = field
          @attributes = attributes
        end

        def field_attributes
          {}
        end

        def focus(value = true)
          @attributes[:autofocus] = value
          self
        end

        private

        def attributes
          field_attributes.merge(@attributes)
        end
      end

      class LabelComponent < FieldComponent
        def template(&content)
          content ||= Proc.new { field.key.to_s.titleize }
          label(**attributes, &content)
        end

        def field_attributes
          { for: dom.id }
        end
      end

      class ButtonComponent < FieldComponent
        def template(&content)
          content ||= Proc.new { button_text }
          button(**attributes, &content)
        end

        def button_text
          @attributes.fetch(:value, dom.value).titleize
        end

        def field_attributes
          { id: dom.id, name: dom.name, value: dom.value }
        end
      end

      class InputComponent < FieldComponent
        def template(&)
          input(**attributes)
        end

        def field_attributes
          { id: dom.id, name: dom.name, value: dom.value, type: type }
        end

        def type
          case field.value
          when URI
            "url"
          when Integer
            "number"
          when Date, DateTime
            "date"
          when Time
            "time"
          else
            "text"
          end
        end
      end

      class TextareaComponent < FieldComponent
        def template(&content)
          content ||= Proc.new { dom.value }
          textarea(**attributes, &content)
        end

        def field_attributes
          { id: dom.id, name: dom.name }
        end
      end
    end
  end
end

module Superform
  module Rails
    module Components
      autoload :CollectionSelect, 'superform/rails/components/collection_select'
    end
  end
end

