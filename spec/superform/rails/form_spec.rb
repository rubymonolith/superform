RSpec.describe Superform::Rails::Form, type: :view do
  let(:model) { User.new(name: "John", email: "john@example.com") }
  let(:form) { described_class.new(model, action: "/users") }

  describe "#initialize" do
    it "creates a form with a model" do
      expect(form.model).to eq(model)
    end

    it "creates a root namespace" do
      expect(form.instance_variable_get(:@namespace)).to be_a(Superform::Namespace)
    end
  end

  describe "#field" do
    it "delegates to the namespace" do
      field = form.field(:email)
      expect(field).to be_a(Superform::Rails::Form::Field)
      expect(field.key).to eq(:email)
    end
  end

  describe "#key" do
    it "returns the model's param key" do
      expect(form.key).to eq("user")
    end
  end

  describe "#render" do
    subject { render(form) }

    it { is_expected.to include('<form') }
    it { is_expected.to include('action="/users"') }
    it { is_expected.to include('method="post"') }
    it { is_expected.to include('name="authenticity_token"') }
    it { is_expected.to include('type="hidden"') }

    context "when model is persisted" do
      let(:model) { User.new(id: 1, name: "John", email: "john@example.com") }
      let(:form) { described_class.new(model, action: "/users/1") }

      it { is_expected.to include('name="_method"') }
      it { is_expected.to include('value="patch"') }
    end

    context "when block is given" do
      subject do
        render(form) do |f|
          f.render f.field(:email).input
          f.render f.field(:name).input
        end
      end

      it { is_expected.to include('name="user[email]"') }
      it { is_expected.to include('name="user[name]"') }
    end

     context "Field kit" do
      subject do
        render(form) do |f|
          f.Field(:email).input
          f.Field(:name).input
          f.namespace(:address).Field(:street).input(type: :email)
        end
      end

      it { is_expected.to include('name="user[email]"') }
      it { is_expected.to include('name="user[name]"') }
      it { is_expected.to include('name="user[address][street]"') }
    end
  end
end
