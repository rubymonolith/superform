module Superform
  class Base
    attr_reader :key

    def initialize(key, parent:)
      @key = key
      @parent = parent
    end
  end

  class Namespace < Base
    attr_reader :object
    include Enumerable

    def initialize(key, parent:, object: nil)
      super(key, parent: parent)
      @object = object
      @children = Hash.new { |h,k| h[k] }
      yield self if block_given?
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

    def namespace_collection(key, &)
      fetch(key) { NamespaceCollection.new(key, parent: self, &) }
    end

    def serialize
      each_with_object Hash.new do |child, hash|
        hash[child.key] = child.serialize
      end
    end

    def each(&)
      @children.values.each(&)
    end

    def assign(hash)
      each do |child|
        child.assign hash[child.key]
      end
      self
    end

    def self.root(*args, **kwargs, &block)
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
    def initialize(key, parent:, value: nil)
      super key, parent: parent
      @value = value
    end

    def value
      if parent_object and parent_object.respond_to? @key
        parent_object.send @key
      else
        @value
      end
    end
    alias :serialize :value

    def assign(value)
      if parent_object and parent_object.respond_to? "#{@key}="
        parent_object.send "#{@key}=", value
      else
        @value = value
      end
    end
    alias :value= :assign

    private

    def parent_object
      @parent.object
    end
  end


  # It's a bit like a field because it has a value ....

  class FieldCollection < Field
    # TODO: This works, but will probably break on `assignment`.
    # def serialize
    #   :not_implemened
    # end
  end

  class NamespaceCollection < Base
    include Enumerable

    def initialize(key, parent:, &template)
      super(key, parent: parent)
      @template = template
      @namespaces = enumerate(parent_collection)
    end

    def serialize
      map(&:serialize)
    end

    def assign(array)
      zip(array) do |namespace, hash|
        namespace.assign hash
      end
    end

    def each(&)
      @namespaces.each(&)
    end

    private

    def enumerate(enumerator)
      Enumerator.new do |y|
        enumerator.each.with_index do |object, key|
          y << build_namespace(key, object: object)
        end
      end
    end

    def build_namespace(index, **kwargs)
      Namespace.new(index, parent: @parent, **kwargs, &@template)
    end

    def parent_collection
      @parent.object.send @key
    end
  end
end

def Superform(...)
  Superform::Namespace.root(...)
end