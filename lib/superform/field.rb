module Superform
  # A Field represents the data associated with a form element. This class provides
  # methods for accessing and modifying the field's value. HTML concerns are all
  # delegated to the DOM object.
  class Field < Node
    attr_reader :dom

    def initialize(key, parent:, object: nil, value: nil)
      super key, parent: parent
      @object = object
      @value = value
      @dom = Superform::DOM.new(field: self)
      yield self if block_given?
    end

    def value
      if @object and @object.respond_to? @key
        @object.send @key
      else
        @value
      end
    end
    alias :serialize :value

    def assign(value)
      if @object and @object.respond_to? "#{@key}="
        @object.send "#{@key}=", value
      else
        @value = value
      end
    end
    alias :value= :assign

    # Wraps a field that's an array of values with a bunch of fields
    # that are indexed with the array's index.
    def collection(&)
      @collection ||= FieldCollection.new(field: self, &)
    end

    class Kit
      def initialize(field:, form:)
        @field = field
        @form = form
      end

      def method_missing(method_name, *, **, &)
        if @field.respond_to?(method_name)
          @form.render @field.send(method_name, *, **, &)
        else
          super
        end
      end
    end

    def kit(form)
      Kit.new(field: self, form:)
    end
  end
end
