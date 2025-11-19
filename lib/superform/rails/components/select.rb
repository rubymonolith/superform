module Superform
  module Rails
    module Components
      class Select < Field
        def initialize(
          *,
          options: [],
          collection: nil,
          multiple: false,
          **,
          &
        )
          super(*, **, &)

          # Handle deprecated collection parameter
          if collection && options.empty?
            warn "[DEPRECATION] Superform::Rails::Components::Select: " \
                 "`collection:` keyword is deprecated and will be removed. " \
                 "Use positional arguments instead: field.select([1, 'A'], [2, 'B'])"
            options = collection
          end

          @options = options
          @multiple = multiple
        end

        def view_template(&block)
          # Hidden input ensures a value is sent even when all options are
          # deselected in a multiple select
          if @multiple
            hidden_name = field.parent.is_a?(Superform::Field) ? dom.name : "#{dom.name}[]"
            input(type: "hidden", name: hidden_name, value: "")
          end

          if block_given?
            select(**attributes, &block)
          else
            select(**attributes) do
              # If first option is nil, render a blank option
              include_blank = @options.first.nil?
              filtered_options = include_blank ? @options[1..] : @options

              blank_option if include_blank
              options(*filtered_options)
            end
          end
        end

        def options(*collection)
          map_options(collection).each do |key, value|
            # Handle both single values and arrays (for multiple selects)
            selected = Array(field.value).include?(key)
            option(selected: selected, value: key) { value }
          end
        end

        def blank_option(&)
          option(selected: field.value.nil?, &)
        end

        def true_option(&)
          option(selected: field.value == true, value: true.to_s, &)
        end

        def false_option(&)
          option(selected: field.value == false, value: false.to_s, &)
        end

        protected
          def map_options(collection)
            OptionMapper.new(collection)
          end

          def field_attributes
            attrs = super
            if @multiple
              # Only append [] if the field doesn't already have a Field parent
              # (which would mean it's already in a collection and has [] notation)
              name = field.parent.is_a?(Superform::Field) ? attrs[:name] : "#{attrs[:name]}[]"
              attrs.merge(multiple: true, name: name)
            else
              attrs
            end
          end
      end
    end
  end
end