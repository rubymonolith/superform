module Superform
  def self.namespace(...)
    Namespace.new(...)
  end

  class Base
    def initialize(key)
      @key = key
    end
  end

  class Namespace < Base
    def initialize(key)
      super
      @children = Hash.new { |h,k| h[k.to_sym] }
      yield self if block_given?
    end

    def field(key)
      fetch(key) { Field.new(key) }
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
      {}
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
  end

  class FieldCollection < Base
  end

  class NamespaceCollection < Base
  end
end