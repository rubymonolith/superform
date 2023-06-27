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
    attr_reader :id, :name, :value, :parent, :children
    attr_writer :value

    def initialize(id, name: nil, value: nil, parent:, builder:)
      @id = id
      @name = name || id
      @value = value
      @parent = parent
      @builder = builder
      @children = []
      yield self if block_given?
    end

    def field(id, value: nil, **kwargs, &)
      value ||= @builder.get(id)
      self.class.new(id, value: value, parent: self, builder: @builder, **kwargs, &).tap do |child|
        @children.append child
      end
    end

    def each(&)
      Array(@value).each.with_index do |value, index|
        self.class.new(index, name: :"", value: value, parent: self, builder: @builder, &).tap do |child|
          @children.append child
        end
      end
    end

    def dom
      DOM.new(self)
    end

    def self.root(*args, **kwargs, &block)
      new *args, parent: nil, **kwargs, &block
    end
  end

  class Mapper
    def attributes(field)
      if field.children.any?
        { field.id => field.children.map { |child| attributes(child) }.reduce(:merge) }
      else
        { field.id => field.value }
      end
    end
  end

  class ParametersMapper < Mapper
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def assign(field)
      field.children.each do |child|
        if value = params.fetch(child.id, nil)
          if child.children.any?
            assign(child)
          else
            child.value = value
          end
        end
      end
    end
  end

  class ObjectMapper < Mapper
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def assign(field)
      field.children.each do |child|
        if object.respond_to?(child.id)
          value = object.send(child.id)
          if child.children.any?
            assign(child)
          else
            child.value = value
          end
        end
      end
    end
  end

  class Builder
    attr_reader :object

    def initialize(object)
      @object = object
    end
  end

  class ObjectBuilder < Builder
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

  class HashBuilder < Builder
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
