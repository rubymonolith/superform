module Superform
  # A Namespace maps and object to values, but doesn't actually have a value itself. For
  # example, a `User` object or ActiveRecord model could be passed into the `:user` namespace.
  # To access the values on a Namespace, the `field` can be called for single values.
  #
  # Additionally, to access namespaces within a namespace, such as if a `User has_many :addresses` in
  # ActiveRecord, the `namespace` method can be called which will return another Namespace object and
  # set the current Namespace as the parent.
  class Namespace < Node
    include Enumerable

    attr_reader :object, :field_class

    def initialize(key, parent:, object: nil, field_class: Field)
      super(key, parent:)
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
    def namespace(key, &)
      @children[key] ||= build_namespace(key, &)
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
    def field(key, &)
      @children[key] ||= build_field(key, &)
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
      @children[key] ||= build_collection(key, &)
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

    # Assigns a hash to the current namespace and children namespace.
    def assign(hash)
      each do |child|
        child.assign hash[child.key]
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

    # Builds a new field child
    def build_field(key, &)
      field_class.new(key, parent: self, object:, &)
    end

    # Builds a new namespace child
    def build_namespace(key, &)
      self.class.new(key, parent: self, object: object_for(key:), field_class:, &)
    end

    # Builds a new collection child
    def build_collection(key, &)
      NamespaceCollection.new(key, parent: self, field_class:, &)
    end
  end
end
