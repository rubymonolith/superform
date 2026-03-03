RSpec.describe Superform::Rails::HTML5::Validations, type: :view do
  describe "#validation_attributes" do
    let(:form) { Superform::Rails::Form.new(model, action: "/test") }

    context "with combined validators" do
      let(:model) { Product.new }

      it "merges all validation attributes" do
        field = form.field(:name)
        attrs = field.validation_attributes
        expect(attrs).to eq({ required: true, minlength: 2, maxlength: 100 })
      end

      it "returns only relevant attributes per field" do
        field = form.field(:quantity)
        attrs = field.validation_attributes
        expect(attrs).to eq({ min: 0, max: 1000, step: 1 })
      end
    end

    context "with conditional validators" do
      let(:model) { ConditionalUser.new }

      it "returns empty hash when all validators are conditional" do
        field = form.field(:username)
        attrs = field.validation_attributes
        expect(attrs).to eq({})
      end
    end
  end

  describe "Field method overrides" do
    let(:model) { User.new }
    let(:form) { Superform::Rails::Form.new(model, action: "/users") }

    describe "#input" do
      it "injects required attribute for presence-validated field" do
        html = render(form) { |f| f.render f.field(:first_name).input }
        expect(html).to include('required')
        expect(html).to include('name="user[first_name]"')
      end

      it "does not inject required for non-validated field" do
        html = render(form) { |f| f.render f.field(:last_name).input }
        expect(html).not_to include('required')
      end

      it "allows user kwargs to override validation attributes" do
        html = render(form) { |f| f.render f.field(:first_name).input(required: false) }
        expect(html).not_to include('required')
      end
    end

    describe "#textarea" do
      it "injects required attribute for presence-validated field" do
        html = render(form) { |f| f.render f.field(:first_name).textarea }
        expect(html).to include('required')
        expect(html).to include('<textarea')
      end
    end

    describe "#checkbox" do
      it "injects required attribute for presence-validated field" do
        html = render(form) { |f| f.render f.field(:first_name).checkbox }
        expect(html).to include('required')
      end
    end

    describe "#select" do
      it "injects required attribute for presence-validated field" do
        html = render(form) { |f| f.render f.field(:first_name).select(["A", "B"]) }
        expect(html).to include('required')
        expect(html).to include('<select')
      end
    end

    describe "#radio" do
      it "injects required attribute for presence-validated field" do
        html = render(form) { |f| f.render f.field(:first_name).radio("male") }
        expect(html).to include('required')
        expect(html).to include('type="radio"')
      end
    end

    describe "convenience methods" do
      let(:model) { Product.new }
      let(:form) { Superform::Rails::Form.new(model, action: "/products") }

      it "injects validation attributes through #number" do
        html = render(form) { |f| f.render f.field(:quantity).number }
        expect(html).to include('type="number"')
        expect(html).to include('min="0"')
        expect(html).to include('max="1000"')
        expect(html).to include('step="1"')
      end

      it "injects validation attributes through #text" do
        html = render(form) { |f| f.render f.field(:name).text }
        expect(html).to include('type="text"')
        expect(html).to include('required')
        expect(html).to include('minlength="2"')
        expect(html).to include('maxlength="100"')
      end
    end
  end

  describe "novalidate" do
    let(:model) { User.new }

    context "when novalidate is false (default)" do
      let(:form) { Superform::Rails::Form.new(model, action: "/users") }

      it "does not add novalidate to form tag" do
        html = render(form)
        expect(html).not_to include('novalidate')
      end

      it "injects validation attributes" do
        html = render(form) { |f| f.render f.field(:first_name).input }
        expect(html).to include('required')
      end
    end

    context "when novalidate is true" do
      let(:novalidate_form_class) do
        Class.new(Superform::Rails::Form) do
          def novalidate = true
        end
      end
      let(:form) { novalidate_form_class.new(model, action: "/users") }

      it "adds novalidate to form tag" do
        html = render(form)
        expect(html).to include('novalidate')
      end

      it "does not inject validation attributes" do
        html = render(form) { |f| f.render f.field(:first_name).input }
        expect(html).not_to match(/required(?!.*novalidate)/)
        # The form tag itself has novalidate, but the input should not have required
        input_tag = html.match(/<input[^>]*name="user\[first_name\]"[^>]*>/)[0]
        expect(input_tag).not_to include('required')
      end
    end
  end
end
