# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superform::Rails::Form::Field, type: :view do
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
    it { expect(field.radio("male").type).to eq("radio") }
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

    it "handles radio button value parameter correctly" do
      component = field.radio("female", class: "radio-input", data: { value: "f" })
      expect(component.type).to eq("radio")
    end
  end

  describe "block handling" do
    # Input elements are void elements and should not accept blocks.
    # These tests verify that blocks are properly ignored.

    it "does not render block content for text input" do
      html = render(field.text { "Block content" })
      expect(html).not_to include("Block content")
      expect(html).to match(/<input[^>]*type="text"[^>]*>/)
    end

    it "does not render block content for email input" do
      html = render(field.email { "Block content" })
      expect(html).not_to include("Block content")
      expect(html).to match(/<input[^>]*type="email"[^>]*>/)
    end

    it "does not render block content for password input" do
      html = render(field.password { "Block content" })
      expect(html).not_to include("Block content")
      expect(html).to match(/<input[^>]*type="password"[^>]*>/)
    end

    it "does not render block content for hidden input" do
      html = render(field.hidden { "Block content" })
      expect(html).not_to include("Block content")
      expect(html).to match(/<input[^>]*type="hidden"[^>]*>/)
    end

    it "does not render block content for number input" do
      html = render(field.number { "Block content" })
      expect(html).not_to include("Block content")
      expect(html).to match(/<input[^>]*type="number"[^>]*>/)
    end

    it "does not render block content for date input" do
      html = render(field.date { "Block content" })
      expect(html).not_to include("Block content")
      expect(html).to match(/<input[^>]*type="date"[^>]*>/)
    end

    it "does not render block content for file input" do
      html = render(field.file { "Block content" })
      expect(html).not_to include("Block content")
      expect(html).to match(/<input[^>]*type="file"[^>]*>/)
    end
  end
end