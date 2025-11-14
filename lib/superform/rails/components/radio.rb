module Superform
  module Rails
    module Components
      class Radio < Field
        def initialize(
          *,
          options: [],
          **,
          &
        )
          super(*, **, &)
          @options = options
        end

        def view_template(&block)
          if block_given?
            yield self
          else
            buttons(*@options)
          end
        end

        def buttons(*collection)
          map_options(collection).each do |value, label|
            button(value) { label }
          end
        end

        def button(value, &block)
          input(
            **attributes,
            type: :radio,
            id: "#{dom.id}_#{value}",
            value: value,
            checked: field.value.to_s == value.to_s
          )
          plain(yield) if block_given?
        end

        protected
          def map_options(collection)
            OptionMapper.new(collection)
          end

          def field_attributes
            { name: dom.name }
          end
      end
    end
  end
end
