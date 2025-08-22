RSpec.describe Superform::Rails::Form do
  let(:model) do
    double("model",
      model_name: double("model_name", param_key: "user"),
      persisted?: false
    )
  end

  let(:form) { described_class.new(model) }

  before do
    # Mock Rails helpers
    allow(form).to receive(:form_authenticity_token).and_return("mock_token")
    allow(form).to receive(:url_for).and_return("/users")
  end

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

  describe "#call" do
    subject { form.call }

    it { is_expected.to include('<form') }
    it { is_expected.to include('action="/users"') }
    it { is_expected.to include('method="post"') }
    it { is_expected.to include('name="authenticity_token"') }
    it { is_expected.to include('value="mock_token"') }

    context "when model is persisted" do
      before { allow(model).to receive(:persisted?).and_return(true) }

      it { is_expected.to include('name="_method"') }
      it { is_expected.to include('value="patch"') }
    end

    context "when block is given" do
      subject do
        form.call do |f|
          f.render f.field(:email).input
          f.render f.field(:name).input
        end
      end

      it { is_expected.to include('name="user[email]"') }
      it { is_expected.to include('name="user[name]"') }
    end
  end
end
