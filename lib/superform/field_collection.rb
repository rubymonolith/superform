module Superform
  # A FieldCollection represents values that are collections of literals. For example, a Note
  # ActiveRecord object might have a collection of tags that's an array of string literals.
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
