module Superform
  module Rails
    class Form
      # The Field class is designed to be extended to create custom forms. To
      # override, in your subclass you may have something like this:
      #
      # ```ruby
      # class MyForm < Superform::Rails::Form
      #   class MyLabel < Superform::Rails::Components::LabelComponent
      #     def template(&content)
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
          Components::ButtonComponent.new(self, attributes: attributes)
        end

        def input(**attributes)
          Components::InputComponent.new(self, attributes: attributes)
        end

        def checkbox(**attributes)
          Components::CheckboxComponent.new(self, attributes: attributes)
        end

        def label(**attributes)
          Components::LabelComponent.new(self, attributes: attributes)
        end

        def textarea(**attributes)
          Components::TextareaComponent.new(self, attributes: attributes)
        end

        def select(*collection, **attributes, &)
          Components::SelectField.new(
            self,
            attributes: attributes,
            collection: collection,
            &
          )
        end

        def title
          key.to_s.titleize
        end
      end
    end
  end
end
