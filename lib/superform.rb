module Superform
  class Base
    attr_reader :key

    def initialize(key, parent:)
      @key = key.to_sym
      @parent = parent
      yield self if block_given?
    end
  end

  class Namespace < Base
    attr_reader :object
    include Enumerable

    def initialize(key, parent:, object: nil)
      @object = object
      @children = Hash.new { |h,k| h[k.to_sym] }
      super(key, parent: parent)
    end

    def namespace(key)
      fetch(key) { Namespace.new(key, parent: self) }
    end

    def field(key)
      fetch(key) { Field.new(key, parent: self) }
    end

    def field_collection(key)
      fetch(key) { FieldCollection.new(key, parent: self) }
    end

    def namespace_collection(key)
      fetch(key) { NamespaceCollection.new(key, parent: self) }
    end

    def serialize
      each_with_object Hash.new do |child, hash|
        hash[child.key] = child.serialize
      end
    end

    def each(&)
      @children.values.each(&)
    end

    def self.root(*args, **kwargs, &block)
      # A nil parent means we're root.
      Superform::Namespace.new(*args, parent: nil, **kwargs, &block)
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

    def initialize(key, parent:, value: nil)
      super key, parent: parent
      @value = value
    end

    def value
      @value ||= object_value
    end
    alias :serialize :value

    private

    def object_value
      @parent.object.send @key if @parent.object.respond_to? @key
    end
  end

  class FieldCollection < Field
    # TODO: This works, but will probably break on `assignment`.
    # def serialize
    #   :not_implemened
    # end
  end

  class NamespaceCollection < Base
    def serialize
      :not_implemened
    end
  end
end

def Superform(...)
  Superform::Namespace.root(...)
end