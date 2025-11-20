# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superform::Rails::Components::Label do
  let(:user) { User.new(first_name: "John") }
  let(:form) { Superform::Rails::Form.new(user) }
  let(:field) { form.field(:first_name) }
  let(:label) { described_class.new(field, attributes: attributes) }
  let(:attributes) { { class: "form-label" } }

  subject { label.call }

  it "renders label with titleized field name" do
    expect(subject).to eq('<label for="user_first_name" class="form-label">First name</label>')
  end

  context "with for: false" do
    let(:attributes) { { class: "form-label", for: false } }

    it "renders label without for attribute" do
      expect(subject).to eq('<label class="form-label">First name</label>')
    end

    it "does not include for attribute" do
      expect(subject).not_to include('for=')
    end
  end

  context "with for: nil" do
    let(:attributes) { { class: "form-label", for: nil } }

    it "renders label without for attribute" do
      expect(subject).to eq('<label class="form-label">First name</label>')
    end
  end

  context "with custom for value" do
    let(:attributes) { { class: "form-label", for: "custom_id" } }

    it "renders label with custom for attribute" do
      expect(subject).to include('for="custom_id"')
      expect(subject).to include('class="form-label"')
      expect(subject).to include('>First name</label>')
    end
  end
end
