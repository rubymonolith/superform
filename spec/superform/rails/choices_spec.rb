RSpec.describe "Radios and Checkboxes components", type: :view do
  describe "radios" do
    let(:object) { double("object", plan_id: 2) }
    let(:field) do
      Superform::Rails::Field.new(:plan_id, parent: nil, object: object)
    end

    it "returns a Components::Radios instance" do
      result = field.radios([1, "Basic"], [2, "Pro"])
      expect(result).to be_a(Superform::Rails::Components::Radios)
    end

    it "renders radios with labels by default (no block)" do
      html = render(field.radios([1, "Basic"], [2, "Pro"]))

      expect(html).to include('type="radio"')
      expect(html).to include('id="plan_id_0"')
      expect(html).to include('id="plan_id_1"')
      expect(html).to include('name="plan_id"')
      expect(html).to include('value="1"')
      expect(html).to include('value="2"')
      expect(html).to include("Basic")
      expect(html).to include("Pro")
      expect(html).to include("<label")
    end

    it "checks the radio matching the field value" do
      html = render(field.radios([1, "Basic"], [2, "Pro"]))

      # plan_id is 2, so Pro (value=2) is checked
      expect(html).to match(/<input[^>]*value="2"[^>]*checked/)
      expect(html).not_to match(/<input[^>]*value="1"[^>]*checked/)
    end

    it "renders with a block for custom markup" do
      component = field.radios([1, "Basic"], [2, "Pro"]) do |choice|
        choice.label do
          choice.input
        end
      end
      html = render(component)

      expect(html).to include('<label')
      expect(html).to include('for="plan_id_0"')
      expect(html).to include('for="plan_id_1"')
      expect(html).to include('type="radio"')
    end

    it "renders choice methods directly without render call in block" do
      component = field.radios([1, "Basic"]) do |choice|
        choice.input
      end
      html = render(component)

      expect(html).to include('type="radio"')
      expect(html).to include('value="1"')
    end

    it "accepts single-value options" do
      html = render(field.radios("basic", "pro"))

      expect(html).to include('value="basic"')
      expect(html).to include('value="pro"')
      expect(html).to include("basic")
      expect(html).to include("pro")
    end

    it "renders a single radio from a single-value option" do
      html = render(field.radios("basic"))

      expect(html).to include('type="radio"')
      expect(html).to include('value="basic"')
      expect(html).to include("basic")
      expect(html).to include("<label")
      expect(html.scan('type="radio"').length).to eq(1)
    end

    it "passes through HTML attributes to radios in block mode" do
      html = render(field.radios([1, "Basic"]) { |choice|
        choice.input(class: "radio-btn")
      })

      expect(html).to include('class="radio-btn"')
    end

    it "accepts a hash of id => label" do
      html = render(field.radios({ 1 => "Basic", 2 => "Pro" }))

      expect(html).to include('value="1"')
      expect(html).to include('value="2"')
      expect(html).to include("Basic")
      expect(html).to include("Pro")
    end
  end

  describe "checkboxes" do
    let(:object) { double("object", role_ids: [1, 3]) }
    let(:field) do
      Superform::Rails::Field.new(:role_ids, parent: nil, object: object)
    end

    it "returns a Components::Checkboxes instance" do
      result = field.checkboxes([1, "Admin"], [2, "Editor"])
      expect(result).to be_a(Superform::Rails::Components::Checkboxes)
    end

    it "renders checkboxes with labels by default (no block)" do
      html = render(field.checkboxes([1, "Admin"], [2, "Editor"], [3, "Viewer"]))

      expect(html).to include('type="checkbox"')
      expect(html).to include('id="role_ids_0"')
      expect(html).to include('id="role_ids_1"')
      expect(html).to include('id="role_ids_2"')
      expect(html).to include('name="role_ids[]"')
      expect(html).to include("Admin")
      expect(html).to include("Editor")
      expect(html).to include("Viewer")
    end

    it "checks checkboxes matching the field value" do
      html = render(field.checkboxes([1, "Admin"], [2, "Editor"], [3, "Viewer"]))

      expect(html).to match(/<input[^>]*checked[^>]*value="1"/)
      expect(html).not_to match(/<input[^>]*checked[^>]*value="2"/)
      expect(html).to match(/<input[^>]*checked[^>]*value="3"/)
    end

    it "renders with a block for custom markup" do
      component = field.checkboxes([1, "Admin"], [2, "Editor"]) do |choice|
        choice.label do
          choice.input
        end
      end
      html = render(component)

      expect(html).to include('<label')
      expect(html).to include('for="role_ids_0"')
      expect(html).to include('for="role_ids_1"')
      expect(html).to include('type="checkbox"')
    end
  end

  describe "enum auto-detection" do
    let(:enum_class) do
      Class.new do
        def self.defined_enums
          { "status" => { "draft" => 0, "published" => 1, "archived" => 2 } }
        end

        def self.try(method)
          send(method) if respond_to?(method)
        end
      end
    end
    let(:object) { enum_class.new.tap { |o| o.define_singleton_method(:status) { "published" } } }
    let(:field) { Superform::Rails::Field.new(:status, parent: nil, object: object) }

    it "auto-detects enum options when no args given" do
      html = render(field.radios)

      expect(html).to include('value="draft"')
      expect(html).to include('value="published"')
      expect(html).to include('value="archived"')
      expect(html).to include("Draft")
      expect(html).to include("Published")
      expect(html).to include("Archived")
    end

    it "checks the radio matching the current value" do
      html = render(field.radios)

      expect(html).to match(/<input[^>]*value="published"[^>]*checked/)
      expect(html).not_to match(/<input[^>]*value="draft"[^>]*checked/)
    end

    it "uses explicit options when provided (skips enum)" do
      html = render(field.radios("active", "inactive"))

      expect(html).to include('value="active"')
      expect(html).to include('value="inactive"')
      expect(html).not_to include('value="draft"')
    end

    it "renders empty when field is not an enum" do
      non_enum_field = Superform::Rails::Field.new(:name, parent: nil, object: object)
      object.define_singleton_method(:name) { "test" }
      html = render(non_enum_field.radios)
      expect(html).to eq("")
    end

    it "renders empty when object is nil" do
      nil_field = Superform::Rails::Field.new(:status, parent: nil, object: nil)
      html = render(nil_field.radios)
      expect(html).to eq("")
    end

    it "works with checkboxes too" do
      html = render(field.checkboxes)

      expect(html).to include('value="draft"')
      expect(html).to include('value="published"')
      expect(html).to include('value="archived"')
      expect(html).to include("Draft")
      expect(html).to include("Published")
      expect(html).to include("Archived")
    end
  end

  describe "default label text" do
    let(:object) { double("object", plan_id: 1) }
    let(:field) do
      Superform::Rails::Field.new(:plan_id, parent: nil, object: object)
    end

    it "renders default labels with choice text in no-block mode" do
      html = render(field.radios([1, "Basic"], [2, "Pro"]))

      expect(html).to include("Basic")
      expect(html).to include("Pro")
      expect(html).to include('for="plan_id_0"')
      expect(html).to include('for="plan_id_1"')
    end

    it "renders choice.text when label is called without a block in block mode" do
      component = field.radios([1, "Basic"], [2, "Pro"]) do |choice|
        choice.label
      end
      html = render(component)

      expect(html).to include("Basic")
      expect(html).to include("Pro")
      expect(html).to include('for="plan_id_0"')
      expect(html).to include('for="plan_id_1"')
    end
  end
end
