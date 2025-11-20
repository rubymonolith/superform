module Superform
  module Rails
    module Components
      class Label < Base
        def view_template(&content)
          content ||= Proc.new { label_text }
          label(**attributes, &content)
        end

        def field_attributes
          # Only include 'for' attribute if explicitly provided or default
          # Skip it if set to false/nil to avoid invalid HTML
          attrs = {}
          for_value = @attributes&.fetch(:for, :default)

          if for_value == :default
            attrs[:for] = dom.id
          elsif for_value
            attrs[:for] = for_value
          end
          # If for_value is false/nil, skip the attribute entirely

          attrs
        end

        def label_text
          field.human_attribute_name
        end
      end
    end
  end
end
