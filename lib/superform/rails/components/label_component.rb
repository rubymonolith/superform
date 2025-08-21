module Superform
  module Rails
    module Components
      class LabelComponent < Base
        def view_template(&content)
          content ||= Proc.new { field.key.to_s.titleize }
          label(**attributes, &content)
        end

        def field_attributes
          { for: dom.id }
        end
      end
    end
  end
end