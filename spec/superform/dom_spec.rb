RSpec.describe Superform::DOM do
  describe "#id" do
    it "returns the id of the field when parent is nil" do
      field = Superform::Field.new("foo", parent: nil)
      dom = field.dom

      expect(dom.id).to eq("foo")
    end

    it "returns the combined id with the parent" do
      parent = Superform::Field.new("parent", parent: nil)
      child = Superform::Field.new("child", parent:)
      dom = child.dom

      expect(dom.id).to eq("parent_child")
    end

    it "returns the combined id when the parent is a namespace" do
      parent = Superform::Namespace.new("parent", parent: nil)
      child = Superform::Field.new("child", parent:)
      dom = child.dom

      expect(dom.id).to eq("parent_child")
    end

    it "returns the combined id when the parent is a collection" do
      grandparent = Superform::Namespace.new(
        "grandparent",
        parent: nil,
        object: double("Collection", parent: nil)
      )
      parent = Superform::NamespaceCollection.new("parent", parent: grandparent)
      child = Superform::Field.new("child", parent:)
      dom = child.dom

      expect(dom.id).to eq("grandparent_parent_child")
    end
  end
end
