module Superform
  module Rails
    module Components
      class Radio < Field
        def initialize(field, value:, index: nil, attributes: {})
          super(field, attributes: attributes)
          @value = value
          @index = index
        end

        def view_template(&)
          input(type: :radio, **attributes)
        end

        def field_attributes
          id = @index ? "#{dom.id}_#{@index}" : dom.id
          { id: id, name: dom.name, value: @value, checked: field.value == @value }
        end
      end
    end
  end
end
