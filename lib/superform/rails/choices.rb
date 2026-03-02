module Superform
  module Rails
    class Choices
      include Enumerable

      def initialize(field:, options:)
        @field = field
        @options = options
      end

      def each(&)
        OptionMapper.new(@options).each_with_index do |(value, text), index|
          yield Choice.new(field: @field, value:, text:, index:)
        end
      end

      class Choice
        attr_reader :value, :text

        def initialize(field:, value:, text:, index:)
          @field = field
          @value = value
          @text = text
          @index = index
        end

        def radio(**attributes)
          @field.radio(@value, index: @index, **attributes)
        end

        def checkbox(**attributes)
          @field.checkbox(value: @value, index: @index, **attributes)
        end

        def label(**attributes, &block)
          label_text = @text
          block ||= proc { label_text }
          Components::Label.new(@field, for: DOM.join(@field.dom.id, @index), **attributes, &block)
        end
      end
    end
  end
end
