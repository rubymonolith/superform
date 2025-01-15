module Superform
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
end
