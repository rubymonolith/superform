module Superform
  module Rails
    module Choices
      class Choice
        attr_reader :value, :text, :index

        def initialize(component:, field:, value:, text:, index:, type:)
          @component = component
          @field = field
          @value = value
          @text = text
          @index = index
          @type = type
        end

        def input(**attrs)
          @component.render build_input(**attrs)
        end

        def label(**attrs, &block)
          label_text = @text
          block ||= proc { label_text }
          @component.render Components::Label.new(
            @field, for: DOM.join(@field.dom.id, @index), **attrs, &block
          )
        end

        def build_input(**attrs)
          case @type
          when :radio
            Components::Radio.new(@field, value: @value, index: @index, **attrs)
          when :checkbox
            Components::Checkbox.new(@field, value: @value, index: @index, **attrs)
          end
        end
      end
    end
  end
end
