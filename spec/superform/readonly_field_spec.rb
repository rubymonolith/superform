# frozen_string_literal: true

RSpec.describe "Readonly Field Functionality" do
  let(:user) { User.new(first_name: "John", email: "john@example.com") }
  let(:form) { Superform::Rails::Form.new(user) }

  describe "Field#readonly" do
    it "sets the field as readonly" do
      field = form.field(:first_name)
      expect(field.read_only?).to be false
      
      field.readonly
      expect(field.read_only?).to be true
    end

    it "can be set with a boolean value" do
      field = form.field(:first_name)
      
      field.readonly(true)
      expect(field.read_only?).to be true
      
      field.readonly(false)
      expect(field.read_only?).to be false
    end

    it "returns self for method chaining" do
      field = form.field(:first_name)
      expect(field.readonly).to eq(field)
    end
  end

  describe "Field#read_only=" do
    it "works as an alias for readonly" do
      field = form.field(:first_name)
      field.read_only = true
      expect(field.read_only?).to be true
    end
  end

  describe "Field#read_only?" do
    context "when field is explicitly set to readonly" do
      it "returns true" do
        field = form.field(:first_name).readonly
        expect(field.read_only?).to be true
      end
    end

    context "when model has readonly attributes" do
      let(:model_class) do
        Class.new do
          attr_accessor :name, :email
          
          def self.readonly_attributes
            ["email"]
          end
          
          def initialize
            @name = "Test"
            @email = "test@example.com"
          end
        end
      end
      
      let(:model) { model_class.new }
      let(:readonly_field) { Superform::Field.new(:email, parent: nil, object: model) }
      let(:writable_field) { Superform::Field.new(:name, parent: nil, object: model) }

      it "returns true for readonly model attributes" do
        expect(readonly_field.read_only?).to be true
      end

      it "returns false for writable model attributes" do
        expect(writable_field.read_only?).to be false
      end
    end

    context "when neither explicit nor model readonly" do
      it "returns false" do
        field = form.field(:first_name)
        expect(field.read_only?).to be false
      end
    end
  end

  describe "Field#assign" do
    context "when field is readonly" do
      it "does not assign the value" do
        field = form.field(:first_name).readonly
        original_value = user.first_name
        
        field.assign("New Name")
        expect(user.first_name).to eq(original_value)
      end
    end

    context "when field is not readonly" do
      it "assigns the value normally" do
        field = form.field(:first_name)
        field.assign("New Name")
        expect(user.first_name).to eq("New Name")
      end
    end
  end

  describe "Input component readonly attribute" do
    it "adds readonly attribute when field is readonly" do
      field = form.field(:first_name).readonly
      input = field.input
      
      rendered = input.call
      expect(rendered).to include('readonly')
    end

    it "does not add readonly attribute when field is not readonly" do
      field = form.field(:first_name)
      input = field.input
      
      rendered = input.call
      expect(rendered).not_to include('readonly')
    end
  end

  describe "Textarea component readonly attribute" do
    it "adds readonly attribute when field is readonly" do
      field = form.field(:first_name).readonly
      textarea = field.textarea
      
      rendered = textarea.call
      expect(rendered).to include('readonly')
    end

    it "does not add readonly attribute when field is not readonly" do
      field = form.field(:first_name)
      textarea = field.textarea
      
      rendered = textarea.call
      expect(rendered).not_to include('readonly')
    end
  end

  describe "Select component readonly behavior" do
    it "adds disabled attribute when field is readonly" do
      field = form.field(:first_name).readonly
      select = field.select(["Option 1", "Option 2"])
      
      rendered = select.call
      expect(rendered).to include('disabled')
    end

    it "does not add disabled attribute when field is not readonly" do
      field = form.field(:first_name)
      select = field.select(["Option 1", "Option 2"])
      
      rendered = select.call
      expect(rendered).not_to include('disabled')
    end
  end

  describe "Checkbox component readonly behavior" do
    it "adds disabled attribute when field is readonly" do
      field = form.field(:first_name).readonly
      checkbox = field.checkbox
      
      rendered = checkbox.call
      expect(rendered).to include('disabled')
    end

    it "does not add disabled attribute when field is not readonly" do
      field = form.field(:first_name)
      checkbox = field.checkbox
      
      rendered = checkbox.call
      expect(rendered).not_to include('disabled')
    end
  end

  describe "Input type methods with readonly attribute" do
    %w[text email password number date time datetime color search url tel file].each do |input_type|
      it "handles readonly attribute for #{input_type} input" do
        field = form.field(:first_name)
        component = field.send(input_type, readonly: true)
        
        expect(field.read_only?).to be true
        rendered = component.call
        expect(rendered).to include('readonly')
      end
    end

    it "handles readonly attribute for radio input" do
      field = form.field(:first_name)
      component = field.radio("value", readonly: true)
      
      expect(field.read_only?).to be true
      rendered = component.call
      expect(rendered).to include('readonly')
    end
  end

  describe "Textarea method with readonly attribute" do
    it "handles readonly attribute" do
      field = form.field(:first_name)
      component = field.textarea(readonly: true)
      
      expect(field.read_only?).to be true
      rendered = component.call
      expect(rendered).to include('readonly')
    end
  end

  describe "Strong parameters with readonly fields" do
    it "excludes readonly fields from assignment" do
      # Create individual fields and test assignment directly
      first_name_field = form.field(:first_name)
      email_field = form.field(:email).readonly
      
      # Test that readonly field doesn't assign
      email_field.assign("new@example.com")
      expect(user.email).to eq("john@example.com") # Should remain unchanged
      
      # Test that regular field does assign
      first_name_field.assign("Jane")
      expect(user.first_name).to eq("Jane")
    end
  end
end