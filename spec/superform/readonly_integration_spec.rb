# frozen_string_literal: true

RSpec.describe "Readonly Field Integration" do
  let(:user) { User.new(first_name: "John", email: "john@example.com") }
  let(:form) { Superform::Rails::Form.new(user) }

  describe "readonly field workflow" do
    it "sets readonly via method call and prevents assignment" do
      field = form.field(:first_name)
      
      # Initially not readonly
      expect(field.read_only?).to be false
      field.assign("Updated")
      expect(user.first_name).to eq("Updated")
      
      # Set to readonly and test prevention
      field.readonly
      expect(field.read_only?).to be true
      field.assign("Should be ignored")
      expect(user.first_name).to eq("Updated") # unchanged
    end

    it "sets readonly via input attributes and renders correctly" do
      # Test with various input types
      text_field = form.field(:first_name).text(readonly: true)
      email_field = form.field(:email).email(readonly: true)
      textarea_field = form.field(:bio).textarea(readonly: true)
      
      # Fields should be marked readonly
      expect(form.field(:first_name).read_only?).to be true
      expect(form.field(:email).read_only?).to be true
      expect(form.field(:bio).read_only?).to be true
      
      # HTML should contain readonly attribute
      expect(text_field.call).to include('readonly')
      expect(email_field.call).to include('readonly')
      expect(textarea_field.call).to include('readonly')
    end

    it "handles readonly for select and checkbox as disabled" do
      # Create readonly select and checkbox
      form.field(:role).readonly
      form.field(:active).readonly
      
      select_component = form.field(:role).select(["admin", "user"])
      checkbox_component = form.field(:active).checkbox
      
      # Should render as disabled
      expect(select_component.call).to include('disabled')
      expect(checkbox_component.call).to include('disabled')
    end

    it "supports all HTML5 input types with readonly" do
      input_types = %w[text email password number date time datetime color search url tel file]
      
      input_types.each do |type|
        field = form.field(:test_field)
        component = field.send(type, readonly: true)
        
        expect(field.read_only?).to be true
        expect(component.call).to include('readonly')
      end
    end

    it "supports method chaining" do
      # Test various chaining patterns
      field1 = form.field(:field1).readonly.text
      field2 = form.field(:field2).text(readonly: true)
      field3 = form.field(:field3).readonly(true)
      
      expect(form.field(:field1).read_only?).to be true
      expect(form.field(:field2).read_only?).to be true
      expect(form.field(:field3).read_only?).to be true
      
      expect(field1.call).to include('readonly')
      expect(field2.call).to include('readonly')
    end

    it "prevents assignment at namespace level" do
      # Create fields with mixed readonly status
      form.field(:first_name)  # writable
      form.field(:email).readonly  # readonly
      
      # Try to assign both fields
      form.assign({
        first_name: "Jane",
        email: "hacker@example.com"
      })
      
      # Only writable field should be updated
      expect(user.first_name).to eq("Jane")
      expect(user.email).to eq("john@example.com") # unchanged
    end

    it "works with model that has readonly_attributes" do
      # Create a simple model with readonly attributes
      model_class = Class.new do
        attr_accessor :name, :status
        
        def self.readonly_attributes
          ["status"]
        end
        
        def initialize
          @name = "Test"
          @status = "active"
        end
      end

      model = model_class.new
      
      # Create fields directly to avoid Rails form complications
      name_field = Superform::Field.new(:name, parent: nil, object: model)
      status_field = Superform::Field.new(:status, parent: nil, object: model)
      
      # Status should be readonly, name should not
      expect(name_field.read_only?).to be false
      expect(status_field.read_only?).to be true
      
      # Test assignment behavior
      name_field.assign("Updated Name")
      status_field.assign("inactive")
      
      expect(model.name).to eq("Updated Name")
      expect(model.status).to eq("active") # unchanged due to readonly
    end

    it "readonly method returns self for chaining" do
      field = form.field(:test)
      result = field.readonly
      
      expect(result).to be(field)
      expect(field.read_only?).to be true
    end

    it "readonly can be set to false to override" do
      field = form.field(:first_name).readonly(true)
      expect(field.read_only?).to be true
      
      field.readonly(false)
      expect(field.read_only?).to be false
      
      # Should allow assignment again
      field.assign("test value")
      expect(user.first_name).to eq("test value")
    end

    it "read_only= alias works" do
      field = form.field(:first_name)
      field.read_only = true
      
      expect(field.read_only?).to be true
    end
  end
end