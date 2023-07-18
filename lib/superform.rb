module Superform
  class Error < StandardError; end

  class DOM
    def initialize(field:)
      @field = field
    end

    def value
      @field.value
    end

    def id
      lineage.map(&:key).join("_")
    end

    def name
      root, *names = lineage.map do |node|
        # If the parent of a field is a field, the name should be nil.
        node.key unless node.parent.is_a? Field
      end
      names.map { |name| "[#{name}]" }.unshift(root).join
    end

    def inspect
      "<id=#{id.inspect} name=#{name.inspect} value=#{value.inspect}/>"
    end

    def lineage
      Enumerator.produce(@field, &:parent).take_while(&:itself).reverse
    end
  end

  class Base
    attr_reader :key, :parent

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

    def namespace(key, &)
      fetch(key) { self.class.new(key, parent: self, object: object_for(key: key), &) }
    end

    def field(key)
      fetch(key) { Field.new(key, parent: self, object: @object) }
    end

    def collection(key, &)
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
      new(*args, parent: nil, **kwargs, &block)
    end

    private

    def fetch(key, &default)
      if @children.key? key
        raise "#{key} already defined"
      else
        @children[key] = default.call
      end
    end

    def object_for(key:)
      @object.send(key) if @object.respond_to? key
    end
  end

  class Field < Base
    attr_reader :dom

    def initialize(key, parent:, object: nil, value: nil)
      super key, parent: parent
      @object = object
      @value = value
      @dom = DOM.new(field: self)
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
    def collection
      Array(value).each.with_index do |value, index|
        yield self.class.new(index, parent: self, value: value)
      end
    end
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
      parent.class.new(index, parent: self, **kwargs, &@template)
    end

    def parent_collection
      @parent.object.send @key
    end
  end
end

def Superform(...)
  Superform::Namespace.root(...)
end