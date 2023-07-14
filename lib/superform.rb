module Superform
  class Base
    attr_reader :key

    def initialize(key)
      @key = key.to_sym
    end
  end

  class Namespace < Base
    attr_reader :object
    include Enumerable

    def initialize(key, object: nil)
      super(key)
      @object = object
      @children = Hash.new { |h,k| h[k.to_sym] }
      yield self if block_given?
    end

    def field(key)
      fetch(key) { Field.new(key, namespace: self) }
    end

    def namespace(key)
      fetch(key) { Namespace.new(key) }
    end

    def field_collection(key)
      fetch(key) { FieldCollection.new(key) }
    end

    def namespace_collection(key)
      fetch(key) { NamespaceCollection.new(key) }
    end

    def serialize
      each_with_object Hash.new do |child, hash|
        hash[child.key] = child.serialize
      end
    end

    def each(&)
      @children.values.each(&)
    end

    private

    def fetch(key, &default)
      if @children.key? key
        raise "#{key} already defined"
      else
        @children[key] = default.call
      end
    end
  end

  class Field < Base
    attr_reader :key
    attr_writer :value

    def initialize(key, namespace:, value: nil)
      super key
      @namespace = namespace
      @value = value
    end

    def value
      @value ||= parent_value
    end
    alias :serialize :value

    private

    def parent_value
      @namespace.object.send @key if @namespace.object.respond_to? @key
    end
  end

  class FieldCollection < Base
    def serialize
      :not_implemened
    end
  end

  class NamespaceCollection < Base
    def serialize
      :not_implemened
    end
  end
end

def Superform(...)
  Superform::Namespace.new(...)
end