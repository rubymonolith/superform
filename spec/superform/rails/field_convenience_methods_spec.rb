# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superform::Rails::Form::Field do
  let(:user) { User.new(email: "test@example.com", first_name: "John") }
  let(:form) { Superform::Rails::Form.new(user) }
  let(:field) { form.field(:email) }

  describe "HTML5 input convenience methods" do
    it { expect(field.text.type).to eq("text") }
    it { expect(field.hidden.type).to eq("hidden") }
    it { expect(field.password.type).to eq("password") }
    it { expect(field.email.type).to eq("email") }
    it { expect(field.url.type).to eq("url") }
    it { expect(field.tel.type).to eq("tel") }
    it { expect(field.phone.type).to eq("tel") }
    it { expect(field.number.type).to eq("number") }
    it { expect(field.range.type).to eq("range") }
    it { expect(field.date.type).to eq("date") }
    it { expect(field.time.type).to eq("time") }
    it { expect(field.datetime.type).to eq("datetime-local") }
    it { expect(field.month.type).to eq("month") }
    it { expect(field.week.type).to eq("week") }
    it { expect(field.color.type).to eq("color") }
    it { expect(field.search.type).to eq("search") }
    it { expect(field.file.type).to eq("file") }
    it do
      component = field.radio(['male', 'Male'], ['female', 'Female'])
      expect(component).to be_a(Superform::Rails::Components::Radio)
    end
  end

  describe "Rails compatibility aliases" do
    describe "#check_box" do
      it "creates checkbox component" do
        component = field.check_box
        expect(component).to be_a(Superform::Rails::Components::Checkbox)
      end
    end

    describe "#text_area" do
      it "creates textarea component" do
        component = field.text_area
        expect(component).to be_a(Superform::Rails::Components::Textarea)
      end
    end
  end

  describe "argument forwarding" do
    it "passes through all attributes correctly" do
      component = field.email(class: "form-input", required: true, placeholder: "Enter email")
      expect(component.type).to eq("email")
    end

    it "allows type override with input method" do
      component = field.input(type: :search, class: "form-input")
      expect(component.type).to eq("search")
    end

    it "handles radio button collection with attributes correctly" do
      component = field.radio(['male', 'Male'], ['female', 'Female'],
                              class: "radio-input", data: { value: "f" })
      expect(component).to be_a(Superform::Rails::Components::Radio)
    end
  end
end