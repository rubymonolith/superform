module Superform
  module Rails
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
    #     def label(**attributes, &)
    #       MyLabel.new(self, **attributes, &)
    #     end
    #
    #     def input(class: nil, **)
    #       super(class: ["input input-outline", grab(class:)])
    #     end
    #   end
    # end
    # ```
    #
    # Now all calls to `label` will have the `text-bold` class applied to it.
    class Field < Superform::Field
      def button(**attributes)
        Components::Button.new(field, **attributes)
      end

      def input(**attributes)
        Components::Input.new(field, **attributes)
      end

      def checkbox(index: nil, **attributes)
        Components::Checkbox.new(field, index:, **attributes)
      end

      def label(**attributes, &)
        Components::Label.new(field, **attributes, &)
      end

      def textarea(**attributes)
        Components::Textarea.new(field, **attributes)
      end

      def select(*options, multiple: false, **attributes, &)
        Components::Select.new(
          field,
          options:,
          multiple:,
          **attributes,
          &
        )
      end

      def datalist(*options, **attributes, &block)
        Components::Datalist.new(field, options:, **attributes, &block)
      end

      def errors
        object.errors[key]
      end

      def invalid?
        errors.any?
      end

      def valid?
        not invalid?
      end

      def human_attribute_name
        object.class.human_attribute_name key
      end

      # HTML5 input type convenience methods - clean API without _field suffix
      # Examples:
      #   field(:email).email(class: "form-input")
      #   field(:age).number(min: 18, max: 99)
      #   field(:birthday).date
      #   field(:secret).hidden(value: "token123")
      #   field(:gender).radio("male", id: "user_gender_male")
      def text(*, **)
        input(*, **, type: :text)
      end

      def hidden(*, **)
        input(*, **, type: :hidden)
      end

      def password(*, **)
        input(*, **, type: :password)
      end

      def email(*, **)
        input(*, **, type: :email)
      end

      def url(*, **)
        input(*, **, type: :url)
      end

      def tel(*, **)
        input(*, **, type: :tel)
      end
      alias_method :phone, :tel

      def number(*, **)
        input(*, **, type: :number)
      end

      def range(*, **)
        input(*, **, type: :range)
      end

      def date(*, **)
        input(*, **, type: :date)
      end

      def time(*, **)
        input(*, **, type: :time)
      end

      def datetime(*, **)
        input(*, **, type: :"datetime-local")
      end

      def month(*, **)
        input(*, **, type: :month)
      end

      def week(*, **)
        input(*, **, type: :week)
      end

      def color(*, **)
        input(*, **, type: :color)
      end

      def search(*, **)
        input(*, **, type: :search)
      end

      def file(*, **)
        input(*, **, type: :file)
      end

      def radio(value, index: value, **attributes)
        Components::Radio.new(field, value:, index:, **attributes)
      end

      def radios(*options, **attributes, &block)
        options = enum_options if options.empty?
        Components::Radios.new(field, options:, **attributes, &block)
      end

      def checkboxes(*options, **attributes, &block)
        options = enum_options if options.empty?
        Components::Checkboxes.new(field, options:, **attributes, &block)
      end

      # Rails compatibility aliases
      alias_method :check_box, :checkbox
      alias_method :text_area, :textarea

      def title
        key.to_s.titleize
      end

      private

      def enum_options
        return [] unless object
        enums = object.class.try(:defined_enums)
        return [] unless enums
        enum = enums[key.to_s]
        return [] unless enum
        enum.keys.map { |k| [k, k.humanize] }
      end
    end
  end
end
