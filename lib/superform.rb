require "zeitwerk"

module Superform
  Loader = Zeitwerk::Loader.for_gem.tap do |loader|
    loader.ignore "#{__dir__}/generators"
    loader.setup
  end

  class Error < StandardError; end

  # Generates DOM IDs, names, etc. for a Field, Namespace, or Node based on
  # norms that were established by Rails. These can be used outsidef or Rails in
  # other Ruby web frameworks since it has now dependencies on Rails.
  class DOM
    def initialize(field:)
      @field = field
    end

    # Converts the value of the field to a String, which is required to work
    # with Phlex. Assumes that `Object#to_s` emits a format suitable for the web form.
    def value
      @field.value.to_s
    end

    # Walks from the current node to the parent node, grabs the names, and seperates
    # them with a `_` for a DOM ID. One limitation of this approach is if multiple forms
    # exist on the same page, the ID may be duplicate.
    def id
      lineage.map(&:key).join("_")
    end

    # The `name` attribute of a node, which is influenced by Rails (not sure where Rails got
    # it from). All node names, except the parent node, are wrapped in a `[]` and collections
    # are left empty. For example, `user[addresses][][street]` would be created for a form with
    # data shaped like `{user: {addresses: [{street: "Sesame Street"}]}}`.
    def name
      root, *names = keys
      names.map { |name| "[#{name}]" }.unshift(root).join
    end

    # Emit the id, name, and value in an HTML tag-ish that doesnt have an element.
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

    # One-liner way of walking from the current node all the way up to the parent.
    def lineage
      Enumerator.produce(@field, &:parent).take_while(&:itself).reverse
    end
  end


  # Superclass for Namespace and Field classes. Not much to it other than it has a `name`
  # and `parent` node attribute. Think of it as a tree.
  class Node
    attr_reader :key, :parent

    def initialize(key, parent:)
      @key = key
      @parent = parent
    end
  end

  # A Namespace maps and object to values, but doesn't actually have a value itself. For
  # example, a `User` object or ActiveRecord model could be passed into the `:user` namespace.
  # To access the values on a Namespace, the `field` can be called for single values.
  #
  # Additionally, to access namespaces within a namespace, such as if a `User has_many :addresses` in
  # ActiveRecord, the `namespace` method can be called which will return another Namespace object and
  # set the current Namespace as the parent.
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

    # Creates a `Namespace` child instance with the parent set to the current instance, adds to
    # the `@children` Hash to ensure duplicate child namespaces aren't created, then calls the
    # method on the `@object` to get the child object to pass into that namespace.
    #
    # For example, if a `User#permission` returns a `Permission` object, we could map that to a
    # form like this:
    #
    # ```ruby
    # Superform :user, object: User.new do |form|
    #   form.namespace :permission do |permission|
    #     form.field :role
    #   end
    # end
    # ```
    def namespace(key, &block)
      create_child(key, self.class, field_class: @field_class, object: object_for(key: key), &block)
    end

    # Maps the `Object#proprety` and `Object#property=` to a field in a web form that can be
    # read and set by the form. For example, a User form might look like this:
    #
    # ```ruby
    # Superform :user, object: User.new do |form|
    #   form.field :email
    #   form.field :name
    # end
    # ```
    def field(key)
      create_child(key, @field_class, object: object).tap do |field|
        yield field if block_given?
      end
    end

    # Wraps an array of objects in Namespace classes. For example, if `User#addresses` returns
    # an enumerable or array of `Address` classes:
    #
    # ```ruby
    # Superform :user, object: User.new do |form|
    #   form.field :email
    #   form.field :name
    #   form.collection :addresses do |address|
    #     address.field(:street)
    #     address.field(:state)
    #     address.field(:zip)
    #   end
    # end
    # ```
    # The object within the block is a `Namespace` object that maps each object within the enumerable
    # to another `Namespace` or `Field`.
    def collection(key, &)
      create_child(key, NamespaceCollection, &)
    end

    # Creates a Hash of Hashes and Arrays that represent the fields and collections of the Superform.
    # This can be used to safely update ActiveRecord objects without the need for Strong Parameters.
    # You will want to make sure that all the fields displayed in the form are ones that you're OK updating
    # from the generated hash.
    def serialize
      each_with_object Hash.new do |child, hash|
        hash[child.key] = child.serialize
      end
    end

    # Iterates through the children of the current namespace, which could be `Namespace` or `Field`
    # objects.
    def each(&)
      @children.values.each(&)
    end

    # Assigns a hash-like to the current namespace and children namespace.
    def assign(hash)
      each do |child|
        child.assign(hash[child.key]) if hash.key?(child.key)
      end
      self
    end

    # Creates a root Namespace, which is essentially a form.
    def self.root(*, **, &)
      new(*, parent: nil, **, &)
    end

    protected

    # Calls the corresponding method on the object for the `key` name, if it exists. For example
    # if the `key` is `email` on `User`, this method would call `User#email` if the method is
    # present.
    #
    # This method could be overwritten if the mapping between the `@object` and `key` name is not
    # a method call. For example, a `Hash` would be accessed via `user[:email]` instead of `user.send(:email)`
    def object_for(key:)
      @object.send(key) if @object.respond_to? key
    end

    private

    # Checks if the child exists. If it does then it returns that. If it doesn't, it will
    # build the child.
    def create_child(key, child_class, **kwargs, &block)
      if (child = @children.fetch(key, nil))
        # ensure that found children are also yielded
        child.tap { yield child if block_given? }
      else
        # new children added to hash and block passed to constructor
        @children[key] = child_class.new(key, parent: self, **kwargs, &block)
      end
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

    def build_field(**)
      @field.class.new(@index += 1, parent: @field, **)
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

    def build_namespace(index, **)
      parent.class.new(index, parent: self, **, &@template)
    end

    def parent_collection
      @parent.object.send @key
    end
  end
end

def Superform(...)
  Superform::Namespace.root(...)
end