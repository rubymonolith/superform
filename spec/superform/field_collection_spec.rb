RSpec.describe Superform::FieldCollection do
  describe "#each" do
    it "yields each field" do
      parent = Superform::Field.new(:foo, parent: nil, object: nil, value: ["A"])
      collection = described_class.new(field: parent)
      enumerator = collection.each
      field = enumerator.next

      expect(field.key).to eq(1)
      expect(field.dom.id).to eq("foo_1")
      expect(field.dom.name).to eq("foo[]")
      expect(field.value).to eq("A")
    end

    it "yields each field when given a block during initialization" do
      parent = Superform::Field.new(:foo, parent: nil, object: nil, value: ["A"])
      collection = described_class.new(field: parent) do |field|
        expect(field.key).to eq(1)
        expect(field.dom.id).to eq("foo_1")
        expect(field.dom.name).to eq("foo[]")
        expect(field.value).to eq("A")
      end
    end
  end
end
