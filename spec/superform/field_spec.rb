RSpec.describe Superform::Field do
  describe "#assign" do
    it "assigns value to the object" do
      object = double("object", "foo=" => nil)
      field = described_class.new("foo", parent: nil, object:)

      expect(object).to receive(:foo=).with("bar")
      field.assign("bar")
    end

    it "sets the value if the object does not respond to" do
      object = double("object")
      field = described_class.new("foo", parent: nil, object:)
      field.assign("bar")

      expect(field.value).to eq("bar")
    end
  end

  describe "#value" do
    it "returns the value of the object" do
      object = double("object", foo: "bar")
      field = described_class.new("foo", parent: nil, object: object)

      expect(field.value).to eq("bar")
    end

    it "returns the value if the object does not respond to" do
      object = double("object")
      field = described_class.new("foo", parent: nil, object: object, value: "bar")

      expect(field.value).to eq("bar")
    end
  end
end
