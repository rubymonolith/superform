module Superform
  module Rails
    module HTML5
      module Validations
        def validation_attributes
          form = find_form
          return {} if form&.respond_to?(:novalidate) && form.novalidate

          ValidationAttributes.new(object, key).to_h
        end

        def input(**attributes)
          super(**validation_attributes, **attributes)
        end

        def checkbox(**attributes)
          super(**validation_attributes, **attributes)
        end

        def textarea(**attributes)
          super(**validation_attributes, **attributes)
        end

        def select(*options, **attributes, &block)
          super(*options, **validation_attributes, **attributes, &block)
        end

        def radio(value, **attributes)
          super(value, **validation_attributes, **attributes)
        end

        private

        def find_form
          node = parent
          while node
            return node.form if node.respond_to?(:form)
            node = node.respond_to?(:parent) ? node.parent : nil
          end
          nil
        end
      end
    end
  end
end
