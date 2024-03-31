RSpec.describe Superform::NamespaceCollection do
  describe "#assign" do
    it "assigns the value to each namespace" do
      object = OpenStruct.new(
        bars: [
          OpenStruct.new(baz: "A"),
          OpenStruct.new(baz: "B")
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
