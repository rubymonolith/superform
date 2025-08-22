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

    # Make the name more obvious for extending or writing docs.
    def field
      self
    end

    class Kit
      def initialize(field:, form:)
        @field = field
        @form = form
        define_field_methods
      end

      private

      def define_field_methods
        # Get all methods that should be excluded (base Ruby/Superform methods)
        base_methods = (Object.instance_methods + Node.instance_methods + 
                       [:dom, :value, :serialize, :assign, :collection, :field, :kit]).to_set
        
        # Get all public methods from the field, including inherited ones
        @field.public_methods.each do |method_name|
          next if base_methods.include?(method_name)
          next if method_name.to_s.end_with?('=')
          
          # Define the method directly on this instance
          define_singleton_method(method_name) do |*args, **kwargs, &block|
            result = @field.send(method_name, *args, **kwargs, &block)
            @form.render result
          end
        end
      end


    end

    def kit(form)
      Kit.new(field:, form:)
    end
  end
end
