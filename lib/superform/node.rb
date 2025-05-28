module Superform
  # Superclass for Namespace and Field classes. Not much to it other than it has a `name`
  # and `parent` node attribute. Think of it as a tree.
  class Node
    attr_reader :key, :parent

    def initialize(key, parent:)
      @key = key
      @parent = parent
      @field_class = nil
    end

    protected

    def field_class
      if parent
        parent.field_class
      else
        @field_class
      end
    end
  end
end
