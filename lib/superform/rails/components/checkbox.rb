module Superform
  module Rails
    module Components
      class Checkbox < Field
        def initialize(field, index: nil, **attributes)
          super(field, **attributes)
          @index = index
        end

        def view_template(&)
          if boolean?
            # Rails convention: hidden input ensures a value is sent even when unchecked
            input(name: dom.name, type: :hidden, value: "0")
            input(type: :checkbox, value: "1", **attributes)
          elsif collection?
            input(type: :checkbox, value: dom.value, **attributes)
          else
            input(type: :checkbox, **attributes)
          end
        end

        def field_attributes
          if boolean?
            { id: dom.id, name: dom.name, checked: field.value }
          elsif collection?
            { id: dom.id, name: dom.name, checked: true }
          else
            { id: DOM.join(dom.id, @index || @attributes[:value]), name: dom.array_name, checked: Array(field.value).include?(@attributes[:value]) }
          end
        end

        private

        # Inside a FieldCollection — the field is a child of another Field
        def collection?
          field.parent.is_a?(Superform::Field)
        end

        # Scalar field with no explicit value — classic on/off toggle
        def boolean?
          !collection? && !field.value.is_a?(Array)
        end
      end
    end
  end
end
