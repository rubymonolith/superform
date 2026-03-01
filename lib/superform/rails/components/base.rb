module Superform
  module Rails
    module Components
      class Base < Component
        attr_reader :field, :dom

        delegate :dom, to: :field

        def initialize(field, attributes: nil, **attributes_kwargs)
          @field = field
          if attributes
            warn "[DEPRECATION] Passing `attributes:` keyword to #{self.class.name} is deprecated. " \
                 "Pass HTML attributes as keyword arguments directly instead: " \
                 "#{self.class.name}.new(field, **attributes)"
            @attributes = attributes.merge(attributes_kwargs)
          else
            @attributes = attributes_kwargs
          end
        end

        def field_attributes
          {}
        end

        def focus(value = true)
          @attributes[:autofocus] = value
          self
        end

        private

        def attributes
          field_attributes.merge(@attributes)
        end
      end
    end
  end
end