module Superform
  module Rails
    module Components
      class Radio < Field
        def initialize(field, value:, attributes: {})
          super(field, attributes: attributes)
          @value = value
        end

        def view_template(&)
          input(type: :radio, **attributes)
        end

        def field_attributes
          { id: dom.id, name: dom.name, value: @value, checked: field.value == @value }
        end
      end
    end
  end
end
