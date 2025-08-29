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
    #     def label(**attributes)
    #       MyLabel.new(self, **attributes)
    #     end
    #   end
    # end
    # ```
    ##
    # Now all calls to `label` will have the `text-bold` class applied to it.
    class Field < Superform::Field
      def button(**attributes)
        Components::Button.new(self, attributes:)
      end

      def input(**attributes)
        Components::Input.new(self, attributes:)
      end

      def checkbox(**attributes)
        Components::Checkbox.new(self, attributes:)
      end

      def label(**attributes, &)
        Components::Label.new(self, attributes:, &)
      end

      def textarea(**attributes)
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
      def text(*, **, &)
        input(*, **, type: :text, &)
      end

      def hidden(*, **, &)
        input(*, **, type: :hidden, &)
      end

      def password(*, **, &)
        input(*, **, type: :password, &)
      end

      def email(*, **, &)
        input(*, **, type: :email, &)
      end

      def url(*, **, &)
        input(*, **, type: :url, &)
      end

      def tel(*, **, &)
        input(*, **, type: :tel, &)
      end
      alias_method :phone, :tel

      def number(*, **, &)
        input(*, **, type: :number, &)
      end

      def range(*, **, &)
        input(*, **, type: :range, &)
      end

      def date(*, **, &)
        input(*, **, type: :date, &)
      end

      def time(*, **, &)
        input(*, **, type: :time, &)
      end

      def datetime(*, **, &)
        input(*, **, type: :"datetime-local", &)
      end

      def month(*, **, &)
        input(*, **, type: :month, &)
      end

      def week(*, **, &)
        input(*, **, type: :week, &)
      end

      def color(*, **, &)
        input(*, **, type: :color, &)
      end

      def search(*, **, &)
        input(*, **, type: :search, &)
      end

      def file(*, **, &)
        input(*, **, type: :file, &)
      end

      def radio(value, *, **, &)
        input(*, **, type: :radio, value: value, &)
      end

      # Rails compatibility aliases
      alias_method :check_box, :checkbox
      alias_method :text_area, :textarea

      def title
        key.to_s.titleize
      end
    end
  end
end
