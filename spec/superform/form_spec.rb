# frozen_string_literal: true

RSpec.describe Superform::Form do
  describe "#call" do
    context "with default method" do
      subject { Superform::Form.new(action: "/users").call }

      it { is_expected.to include('action="/users"') }
      it { is_expected.to include('method="post"') }
    end

    context "with custom method and attributes" do
      subject { Superform::Form.new(action: "/users", method: :patch, class: "my-form").call }

      it { is_expected.to include('action="/users"') }
      it { is_expected.to include('method="patch"') }
      it { is_expected.to include('class="my-form"') }
    end

    context "without action" do
      subject { Superform::Form.new(class: "simple").call }

      it { is_expected.to include('method="post"') }
      it { is_expected.to include('class="simple"') }
    end
  end

  describe "#build_field" do
    it "creates a Field instance" do
      form = Superform::Form.new
      field = form.build_field(:email, parent: nil)

      expect(field).to be_a(Superform::Field)
      expect(field.key).to eq(:email)
    end
  end
end
