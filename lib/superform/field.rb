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

    # High-performance Kit proxy that wraps field methods with form.render calls.
    # Uses Ruby class hooks to define methods at the class level for maximum speed:
    # - Methods are defined once per Field class, not per Kit instance
    # - True Ruby methods with full VM optimization (no method_missing overhead)
    # - ~125x faster Kit instantiation compared to instance-level dynamic methods
    # - Each Field subclass gets its own isolated Kit class with true isolation:
    #   * Methods are copied at subclass creation time, not inherited dynamically
    #   * Adding methods to a parent Field class won't affect existing subclass Kits
    #   * Perfect for library design where you don't want parent changes affecting subclasses
    class Kit
      def initialize(field:, form:)
        @field = field
        @form = form
      end
    end

    def self.inherited(subclass)
      super
      # Create a new Kit class for each Field subclass with true isolation
      # Copy methods from parent Field classes at creation time, not through inheritance
      subclass.const_set(:Kit, Class.new(Field::Kit))
      
      # Copy all existing methods from the inheritance chain
      field_class = self
      while field_class != Field
        copy_field_methods_to_kit(field_class, subclass::Kit)
        field_class = field_class.superclass
      end
    end

    def self.method_added(method_name)
      super
      # Skip if this is the base Field class or if we don't have a Kit class yet
      return if self == Field
      return unless const_defined?(:Kit, false)
      
      # Only add method to THIS class's Kit, not subclasses (isolation)
      add_method_to_kit(method_name, self::Kit)
    end

    def kit(form)
      self.class::Kit.new(field: self, form: form)
    end

    private

    def self.copy_field_methods_to_kit(field_class, kit_class)
      base_methods = (Object.instance_methods + Node.instance_methods + 
                     [:dom, :value, :serialize, :assign, :collection, :field, :kit]).to_set
      
      field_class.instance_methods(false).each do |method_name|
        next if method_name.to_s.end_with?('=')
        next if base_methods.include?(method_name)
        next if kit_class.method_defined?(method_name)
        
        kit_class.define_method(method_name) do |*args, **kwargs, &block|
          result = @field.send(method_name, *args, **kwargs, &block)
          @form.render result
        end
      end
    end

    def self.add_method_to_kit(method_name, kit_class)
      return if method_name.to_s.end_with?('=')
      
      base_methods = (Object.instance_methods + Node.instance_methods + 
                     [:dom, :value, :serialize, :assign, :collection, :field, :kit]).to_set
      return if base_methods.include?(method_name)
      return if kit_class.method_defined?(method_name)
      
      kit_class.define_method(method_name) do |*args, **kwargs, &block|
        result = @field.send(method_name, *args, **kwargs, &block)
        @form.render result
      end
    end
  end
end
