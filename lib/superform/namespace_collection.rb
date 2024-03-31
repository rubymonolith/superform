module Superform
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

    def build_namespace(index, **)
      parent.class.new(index, parent: self, **, &@template)
    end

    def parent_collection
      @parent.object.send @key
    end
  end
end
