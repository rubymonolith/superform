RSpec.describe Superform::NamespaceCollection do
  Bar = Struct.new(:baz, keyword_init: true)
  TestObject = Struct.new(:bars, keyword_init: true)

  describe "#assign" do
    it "assigns the value to each namespace" do
      object = TestObject.new(
        bars: [
          Bar.new(baz: "A"),
          Bar.new(baz: "B")
        ]
      )

      namespace = Superform::Namespace.new(:foo, parent: nil, object:)
      collection = described_class.new(:bars, parent: namespace) do |collection|
        collection.field(:baz)
      end

      collection.assign([{ baz: "C" },{ baz: "D" }])
      expect(collection.serialize).to eq([{ baz: "C" },{ baz: "D" }])
    end
  end
end
