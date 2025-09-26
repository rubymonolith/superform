# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superform::Rails::Components::Label do
  let(:user) { User.new(first_name: "John") }
  let(:form) { Superform::Rails::Form.new(user) }
  let(:field) { form.field(:first_name) }
  let(:label) { described_class.new(field, attributes: { class: "form-label" }) }

  subject { label.call }

  it "renders label with titleized field name" do
    expect(subject).to eq('<label for="user_first_name" class="form-label">First name</label>')
  end
end
