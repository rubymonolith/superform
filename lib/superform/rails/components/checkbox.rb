module Superform
  module Rails
    module Components
      class Checkbox < Field
        def initialize(field, *option_list, **, &)
          super(field, **, &)
          @options = option_list
        end

        def view_template(&block)
          if array_mode? || block_given?
            # Array mode: render multiple checkboxes
            if block_given?
              yield self
            else
              options(*@options)
            end
          else
            # Boolean mode: single checkbox with hidden field
            # Rails has a hidden and checkbox input to deal with sending back
            # a value to the server regardless of if the input is checked or not.
            input(name: dom.name, type: :hidden, value: "0")
            # The hard coded keys need to be in here so the user can't overrite them.
            input(type: :checkbox, value: "1", **attributes)
          end
        end

        # Array mode methods
        def options(*option_list)
          map_options(option_list).each do |value, label|
            option(value) { label }
          end
        end

        def option(value, &block)
          label do
            input(
              **attributes,
              type: :checkbox,
              id: "#{dom.id}_#{value}",
              name: "#{dom.name}[]",
              value: value.to_s,
              checked: checked_in_array?(value)
            )
            plain(yield) if block_given?
          end
        end

        protected
          def array_mode?
            @options.any?
          end

          def map_options(option_list)
            OptionMapper.new(option_list)
          end

          def checked_in_array?(value)
            # Checkbox arrays are multi-select, so field.value should be an array
            field_value = field.value
            return false if field_value.nil?

            field_value = [field_value] unless field_value.is_a?(Array)
            field_value.map(&:to_s).include?(value.to_s)
          end

          def field_attributes
            if array_mode?
              # option method handles all attributes explicitly
              {}
            else
              { id: dom.id, name: dom.name, checked: field.value }
            end
          end
      end
    end
  end
end