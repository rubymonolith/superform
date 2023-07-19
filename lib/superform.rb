module Superform
  class Error < StandardError; end

  class DOM
    def initialize(field:)
      @field = field
    end

    def value
      @field.value.to_s
    end

    def id
      lineage.map(&:key).join("_")
    end

    def name
      root, *names = keys
      names.map { |name| "[#{name}]" }.unshift(root).join
    end

    def inspect
      "<id=#{id.inspect} name=#{name.inspect} value=#{value.inspect}/>"
    end

    private

    def keys
      lineage.map do |node|
        # If the parent of a field is a field, the name should be nil.
        node.key unless node.parent.is_a? Field
      end
    end

    def lineage
      Enumerator.produce(@field, &:parent).take_while(&:itself).reverse
    end
  end

  class Node
    attr_reader :key, :parent

    def initialize(key, parent:)
      @key = key
      @parent = parent
    end
  end

  class Namespace < Node
    include Enumerable

    attr_reader :object

    def initialize(key, parent:, object: nil, field_class: Field)
      super(key, parent: parent)
      @object = object
      @field_class = field_class
      @children = Hash.new
      yield self if block_given?
    end

    def namespace(key, &block)
      create_child(key, self.class, object: object_for(key: key), &block)
    end

    def field(key)
      create_child(key, @field_class, object: object)
    end

    def collection(key, &block)
      create_child(key, NamespaceCollection, &block)
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

    def create_child(key, child_class, **options, &block)
      fetch(key) { child_class.new(key, parent: self, **options, &block) }
    end

    def fetch(key, &build)
      @children[key] ||= build.call
    end

    def object_for(key:)
      @object.send(key) if @object.respond_to? key
    end
  end

  class Field < Node
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
    def collection(&)
      @collection ||= FieldCollection.new(field: self, &)
    end
  end

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

    def build_field(**kwargs)
      @field.class.new(@index += 1, parent: @field, **kwargs)
    end
  end

  class NamespaceCollection < Node
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
      # The problem with zip-ing the array is if I need to add new
      # elements to it and wrap it in the namespace.
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