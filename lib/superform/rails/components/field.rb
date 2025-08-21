module Superform
  module Rails
    module Components
      class Field < Base
        def field_attributes
          { id: dom.id, name: dom.name }
        end
      end
    end
  end
end