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

        def buttons(*option_list)
          map_options(option_list).each do |value, label|
            button(value) { label }
          end
        end

        def button(value, &block)
          input(
            **attributes,
            type: :radio,
            id: "#{dom.id}_#{value}",
            value: value,
            checked: checked?(value)
          )
          plain(yield) if block_given?
        end

        protected
          def map_options(option_list)
            OptionMapper.new(option_list)
          end

          def checked?(value)
            # Radio buttons are single-select, so field.value should never be an array
            field.value.to_s == value.to_s
          end

          def field_attributes
            { name: dom.name }
          end
      end
    end
  end
end
