module Superform
  class FieldCollection
    include Enumerable

    def initialize(field:, &)
      @field = field
      @index = 0
      each(&) if block_given?
    end

    def each(&)
      values.each do |value|
        yield build_field(value: value)
      end
    end

    def field
      build_field
    end

    def values
      Array(@field.value)
    end

    private

    def build_field(**)
      @field.class.new(@index += 1, parent: @field, **)
    end
  end
end
