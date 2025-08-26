module Superform
  module Rails
    # A Phlex::HTML view module that accepts a model and sets a `Superform::Namespace`
    # with the `Object#model_name` as the key and maps the object to form fields
    # and namespaces.
    #
    # The `Form::Field` is a class that's meant to be extended so you can customize the `Form` inputs
    # to your applications needs. Defaults for the `input`, `button`, `label`, and `textarea` tags
    # are provided.
    #
    # The `Form` component also handles Rails authenticity tokens via the `authenticity_toklen_field`
    # method and the HTTP verb via the `_method_field`.
    class Form < Component
      include Phlex::Rails::Helpers::FormAuthenticityToken
      include Phlex::Rails::Helpers::URLFor

      attr_accessor :model

      delegate \
          :Field,
          :field,
          :collection,
          :namespace,
          :assign,
          :serialize,
        to: :@namespace

      # The Field class is designed to be extended to create custom forms. To override,
      # in your subclass you may have something like this:
      #
      # ```ruby
      # class MyForm < Superform::Rails::Form
      #   class MyLabel < Superform::Rails::Components::Label
      #     def view_template(&content)
      #       label(form: @field.dom.name, class: "text-bold", &content)
      #     end
      #   end
      #
      #   class Field < Field
      #     def label(**attributes)
      #       MyLabel.new(self, **attributes)
      #     end
      #   end
      # end
      # ```
      #
      # Now all calls to `label` will have the `text-bold` class applied to it.
      class Field < Superform::Field
        def button(**attributes)
          Components::Button.new(self, attributes:)
        end

        def input(**attributes)
          handle_readonly_attribute(attributes)
          Components::Input.new(self, attributes:)
        end

        def text(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :text, &)
        end

        def checkbox(**attributes)
          Components::Checkbox.new(self, attributes:)
        end

        def label(**attributes, &)
          Components::Label.new(self, attributes:, &)
        end

        def textarea(**attributes)
          handle_readonly_attribute(attributes)
          Components::Textarea.new(self, attributes:)
        end

        def select(*collection, **attributes, &)
          Components::Select.new(self, attributes:, collection:, &)
        end

        # HTML5 input type convenience methods - clean API without _field suffix
        # Examples:
        #   field(:email).email(class: "form-input")
        #   field(:age).number(min: 18, max: 99)
        #   field(:birthday).date
        #   field(:secret).hidden(value: "token123")
        #   field(:gender).radio("male", id: "user_gender_male")
        def hidden(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :hidden, &)
        end

        def password(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :password, &)
        end

        def email(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :email, &)
        end

        def url(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :url, &)
        end

        def tel(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :tel, &)
        end
        alias_method :phone, :tel

        def number(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :number, &)
        end

        def range(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :range, &)
        end

        def date(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :date, &)
        end

        def time(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :time, &)
        end

        def datetime(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :"datetime-local", &)
        end

        def month(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :month, &)
        end

        def week(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :week, &)
        end

        def color(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :color, &)
        end

        def search(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :search, &)
        end

        def file(*, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :file, &)
        end

        def radio(value, *, **attributes, &)
          handle_readonly_attribute(attributes)
          input(*, **attributes, type: :radio, value: value, &)
        end

        # Rails compatibility aliases
        alias_method :check_box, :checkbox
        alias_method :text_area, :textarea

        def title
          key.to_s.titleize
        end

        private

        def handle_readonly_attribute(attributes)
          if attributes[:readonly] || attributes['readonly']
            readonly(true)
            # Remove from attributes since it's handled by the field
            attributes.delete(:readonly)
            attributes.delete('readonly')
          end
        end
      end

      def build_field(...)
        self.class::Field.new(...)
      end

      def initialize(model, action: nil, method: nil, **attributes)
        @model = model
        @action = action
        @method = method
        @attributes = attributes
        @namespace = Namespace.root(key, object: model, form: self)
      end

      def around_template(&)
        form_tag do
          authenticity_token_field
          _method_field
          super
        end
      end

      def form_tag(&)
        form action: form_action, method: form_method, **@attributes, &
      end

      def view_template(&block)
        yield self if block_given?
      end

      def submit(value = submit_value, **attributes)
        input **attributes.merge(
          name: "commit",
          type: "submit",
          value: value
        )
      end

      def key
        @model.model_name.param_key
      end

      protected
        def authenticity_token_field
          input(
            name: "authenticity_token",
            type: "hidden",
            value: form_authenticity_token
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
          @method || resource_method_field_value
        end

        def resource_method_field_value
          @model.persisted? ? "patch" : "post"
        end

        def submit_value
          "#{resource_action.to_s.capitalize} #{@model.model_name}"
        end

        def resource_action
          @model.persisted? ? :update : :create
        end

        def form_action
          @action ||= url_for(action: resource_action)
        end

        def form_method
          @method.to_s.downcase == "get" ? "get" : "post"
        end
    end
  end
end
