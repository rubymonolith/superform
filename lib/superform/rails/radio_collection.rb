module Superform
  module Rails
    class RadioCollection
      include Enumerable

      def initialize(field:, options:)
        @field = field
        @options = options
        @index = 0
      end

      def each
        OptionMapper.new(@options).each do |value, label|
          @index += 1
          yield RadioOption.new(field: @field, value: value, label: label, index: @index)
        end
      end
    end

    class RadioOption
      attr_reader :value, :label

      def initialize(field:, value:, label:, index:)
        @field = field
        @value = value
        @label = label
        @index = index
      end

      def radio(**attributes)
        Components::Radio.new(@field, value: @value, index: @index, attributes: attributes)
      end
    end
  end
end
