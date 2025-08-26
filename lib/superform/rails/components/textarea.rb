module Superform
  module Rails
    module Components
      class Textarea < Field
        def view_template(&content)
          content ||= Proc.new { dom.value }
          textarea(**attributes, &content)
        end

        def field_attributes
          attrs = {
            id: dom.id,
            name: dom.name
          }
          attrs[:readonly] = true if field.read_only?
          attrs
        end
      end
    end
  end
end