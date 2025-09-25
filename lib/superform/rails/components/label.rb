module Superform
  module Rails
    module Components
      class Label < Base
        def view_template(&content)
          content ||= Proc.new { label_text }
          label(**attributes, &content)
        end

        def field_attributes
          { for: dom.id }
        end

        def label_text
          field.human_attribute_name
        end
      end
    end
  end
end
