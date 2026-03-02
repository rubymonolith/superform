module Superform
  module Rails
    module Components
      class Radio < Field
        def initialize(field, value:, index: value, **attributes)
          super(field, **attributes)
          @value = value
          @index = index
        end

        def view_template(&)
          input(type: :radio, **attributes)
        end

        def field_attributes
          { id: DOM.join(dom.id, @index), name: dom.name, value: @value, checked: field.value == @value }
        end
      end
    end
  end
end
