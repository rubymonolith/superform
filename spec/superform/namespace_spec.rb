RSpec.describe Superform::Namespace do
  describe "#namespace" do
    it "yields a child namespace" do
      parent = described_class.new(:foo, parent: nil, object: nil)
      parent.namespace(:bar) do |child|
        expect(child).to be_a(described_class)
        expect(child.key).to eq(:bar)
      end
    end
  end

  describe "#field" do
    it "yields the field" do
      parent = described_class.new(:foo, parent: nil, object: nil)
      parent.field(:bar) do |child|
        expect(child).to be_a(Superform::Field)
        expect(child.key).to eq(:bar)
      end
    end
  end

  describe "#collection" do
    it "yields a namespace collection" do
      parent = described_class.new(
        :foo,
        parent: nil,
        object: double("object", bar: [{ baz: "A" }])
      )

      parent.collection(:bar) do |child|
        expect(child).to be_a(Superform::Namespace)
        expect(child.key).to eq(0)
      end
    end
  end

  describe "#serialize" do
    it "returns the serialized representation of the fields" do
      object = double("object", bar: "A", baz: "B")
      namespace = described_class.new(:foo, parent: nil, object:) do |parent|
        parent.field(:bar)
        parent.field(:baz)
      end

      expect(namespace.serialize).to eq({ bar: "A", baz: "B" })
    end
  end

  describe "#each" do
    it "yields each field" do
      namespace = described_class.new(:foo, parent: nil, object: nil) do |parent|
        parent.field(:bar)
        parent.field(:baz)
      end

      enumerator = namespace.each

      expect(enumerator.next.key).to eq(:bar)
      expect(enumerator.next.key).to eq(:baz)
    end
  end

  describe "#assign" do
    it "assigns the value to the fields" do
      namespace = described_class.new(:foo, parent: nil, object: nil) do |parent|
        parent.field(:bar)
        parent.field(:baz)
      end

      values = { bar: "A", baz: "B" }
      namespace.assign(values)
      namespace.each do |field|
        expect(field.value).to eq(values[field.key])
      end
    end
  end
end
