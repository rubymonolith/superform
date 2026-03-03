RSpec.describe Superform::Rails::HTML5::ValidationAttributes do
  subject(:validation_attributes) { described_class.new(object, key) }

  describe "#to_h" do
    context "presence" do
      let(:object) { User.new }

      context "with presence validator" do
        let(:key) { :first_name }

        it "returns required: true" do
          expect(validation_attributes.to_h).to include(required: true)
        end
      end

      context "without presence validator" do
        let(:key) { :last_name }

        it "returns empty hash" do
          expect(validation_attributes.to_h).to eq({})
        end
      end
    end

    context "length" do
      let(:object) { Product.new }

      it "returns minlength and maxlength for minimum/maximum" do
        expect(described_class.new(object, :name).to_h).to include(minlength: 2, maxlength: 100)
      end

      it "returns minlength and maxlength for in: range" do
        expect(described_class.new(object, :description).to_h).to eq({ minlength: 10, maxlength: 500 })
      end
    end

    context "numericality" do
      let(:object) { Product.new }

      it "returns min, max, and step for integer field with bounds" do
        expect(described_class.new(object, :quantity).to_h).to include(min: 0, max: 1000, step: 1)
      end

      it "returns min for field with only greater_than_or_equal_to" do
        expect(described_class.new(object, :price).to_h).to eq({ min: 0 })
      end
    end

    context "combined validators" do
      let(:object) { Product.new }

      it "merges all validation attributes for a field" do
        expect(described_class.new(object, :name).to_h).to eq({ required: true, minlength: 2, maxlength: 100 })
      end
    end

    context "conditional validators" do
      let(:object) { ConditionalUser.new }

      it "skips validators with if: option" do
        expect(described_class.new(object, :username).to_h).to eq({})
      end

      it "skips validators with on: option" do
        expect(described_class.new(object, :email).to_h).to eq({})
      end
    end

    context "object without validators" do
      let(:object) { double("plain object") }
      let(:key) { :anything }

      it "returns empty hash" do
        expect(validation_attributes.to_h).to eq({})
      end
    end
  end
end
