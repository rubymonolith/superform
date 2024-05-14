RSpec.describe Superform::Rails::Components::InputComponent do
  let(:field) do
    object = double("object", "foo=": nil)
    Superform::Field.new(:foo, parent: nil, object:)
  end
  let(:attributes) do
    {}
  end
  let(:component) do
    described_class.new(field, attributes: attributes)
  end
  subject { component }

  context "type: :text" do
    it { is_expected.to_not have_client_provided_value }
    it "is type: :text by default" do
      expect(subject.type).to be_text
    end
  end

  context "type: :image" do
    let(:attributes) do
      { type: :image }
    end
    it { is_expected.to have_client_provided_value }
  end

  context "type: 'file'" do
    let(:attributes) do
      { type: "file" }
    end
    it { is_expected.to have_client_provided_value }
  end
end
