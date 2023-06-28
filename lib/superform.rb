# frozen_string_literal: true

require_relative "superform/version"

module Superform
  class Error < StandardError; end

  class DOM
    def initialize(field)
      @field = field
    end

    def value
      @field.value
    end

    def id
      lineage.map(&:id).join("_")
    end

    def name
      root, *names = lineage.map(&:name)
      names.map { |name| "[#{name}]" }.unshift(root).join
    end

    def inspect
      "<id=#{id.inspect} name=#{name.inspect} value=#{value.inspect}/>"
    end

    def lineage
      Enumerator.produce(@field, &:parent).take_while(&:itself).reverse
    end
  end

  class Field
    attr_reader :id, :name, :value, :parent, :children, :dom
    attr_writer :value, :children

    def initialize(id, parent:, name: nil, value: nil, mapper: nil, serializer: Serializer)
      @id = id
      @name = name || id
      @value = value
      @parent = parent
      @mapper = mapper || Mapper.for(value)
      @serializer = Serializer.new(self)
      @dom = DOM.new(self)
      @children = []
      yield self if block_given?
    end

    def serialize
      @serializer.serialize
    end

    def assign(object)
      @serializer.assign(object)
      self
    end

    def field(id, value: nil, **kwargs, &)
      value ||= @mapper.get(id)
      self.class.new(id, value: value, parent: self, **kwargs, &).tap do |child|
        @children.append child
      end
    end

    def inspect
      @dom.inspect
    end

    def each(&block)
      @serializer = CollectionSerializer.new(self, &block)
      Array(@value).each.with_index do |value, index|
        @serializer.build_field(index, value: value).tap do |child|
          @children.append child
        end
      end
    end

    def self.root(*args, **kwargs, &block)
      new *args, parent: nil, **kwargs, &block
    end
  end

  class Serializer
    attr_reader :field

    def initialize(field)
      @field = field
    end

    def serialize
      if field.children.any?
        field.children.each_with_object Hash.new do |field, hash|
          hash[field.id] = field.serialize
        end
      else
        field.value
      end
    end

    def assign(object)
      mapper = Mapper.for(object)
      field.children.each do |child|
        if value = mapper.get(child.id)
          if child.children.any?
            child.assign value
          else
            child.value = value
          end
        end
      end
    end
  end

  class CollectionSerializer < Serializer
    attr_reader :template

    def initialize(*args, **kwargs, &template)
      super *args, **kwargs
      @template = template
    end

    def serialize
      field.children.map(&:serialize)
    end

    def assign(collection)
      field.value = collection
      field.children = []
      collection.each.with_index do |value, index|
        build_field(index, value: value).tap do |child|
          field.children.append child
          child.assign value
        end
      end
    end

    def build_field(index, value: nil)
      Field.new(index, name: :"", value: value, parent: field, &@template)
    end
  end

  class Mapper
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def self.for(object)
      case object
      when Hash
        HashMapper.new(object)
      when Mapper
        object
      else
        ObjectMapper.new(object)
      end
    end
  end

  class ObjectMapper < Mapper
    def get(key)
      @object.send key if key? key
    end

    def set(key, value)
      @object.send "#{key}=", value if @object.respond_to? "#{key}="
    end

    def key?(key)
      @object.respond_to? key
    end
  end

  class HashMapper < Mapper
    def get(key)
      @object.fetch key if key? key
    end

    def set(key, value)
      @object[key] = value
    end

    def key?(key)
      @object.key? key
    end
  end
end
