module Superform
  module Rails
    module Components
      class FieldComponent < BaseComponent
        def field_attributes
          { id: dom.id, name: dom.name }
        end
      end
    end
  end
end
