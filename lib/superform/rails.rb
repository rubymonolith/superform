module Superform
  module Rails
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
        form action: form_action, method: form_method do
          authenticity_token_field
          _method_field
          super
        end
      end

      def template(&block)
        yield_content(&block)
      end

      def submit(value = submit_value)
        input(
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
        def template(&)
          label(**attributes) { field.key.to_s.titleize }
        end

        def field_attributes
          { for: dom.id }
        end
      end

      class ButtonComponent < FieldComponent
        def template(&block)
          button(**attributes) { button_text }
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
        def template(&)
          textarea(**attributes) { dom.value }
        end

        def field_attributes
          { id: dom.id, name: dom.name }
        end
      end
    end
  end
end