module Superform
  module Rails
    module Components
      class ButtonComponent < FieldComponent
        def view_template(&content)
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
    end
  end
end
