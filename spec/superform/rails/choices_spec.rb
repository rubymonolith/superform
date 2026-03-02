RSpec.describe Superform::Rails::Choices, type: :view do
  describe "radios" do
    let(:object) { double("object", plan_id: 2) }
    let(:field) do
      Superform::Rails::Field.new(:plan_id, parent: nil, object: object)
    end

    it "iterates over options yielding Choice objects" do
      choices = field.radios([1, "Basic"], [2, "Pro"], [3, "Enterprise"])
      values = choices.map { |c| [c.value, c.text] }
      expect(values).to eq([[1, "Basic"], [2, "Pro"], [3, "Enterprise"]])
    end

    it "renders radios with index-based ids" do
      html = ""
      field.radios([1, "Basic"], [2, "Pro"]).each do |choice|
        html += render(choice.radio)
      end

      expect(html).to include('id="plan_id_0"')
      expect(html).to include('id="plan_id_1"')
      expect(html).to include('name="plan_id"')
      expect(html).to include('value="1"')
      expect(html).to include('value="2"')
    end

    it "checks the radio matching the field value" do
      html = ""
      field.radios([1, "Basic"], [2, "Pro"]).each do |choice|
        html += render(choice.radio)
      end

      # plan_id is 2, so Pro (value=2) is checked
      expect(html).to match(/<input[^>]*value="2"[^>]*checked/)
      expect(html).not_to match(/<input[^>]*value="1"[^>]*checked/)
    end

    it "renders labels with matching for attributes" do
      html = ""
      field.radios([1, "Basic"], [2, "Pro"]).each do |choice|
        html += render(choice.label { choice.text })
        html += render(choice.radio)
      end

      expect(html).to include('for="plan_id_0"')
      expect(html).to include('for="plan_id_1"')
    end

    it "accepts single-value options" do
      choices = field.radios("basic", "pro")
      values = choices.map { |c| [c.value, c.text] }
      expect(values).to eq([["basic", "basic"], ["pro", "pro"]])
    end

    it "passes through HTML attributes to radios" do
      html = ""
      field.radios([1, "Basic"]).each do |choice|
        html += render(choice.radio(class: "radio-btn"))
      end

      expect(html).to include('class="radio-btn"')
    end

    it "accepts a hash of id => label" do
      choices = field.radios({ 1 => "Basic", 2 => "Pro" })
      values = choices.map { |c| [c.value, c.text] }
      expect(values).to eq([[1, "Basic"], [2, "Pro"]])
    end
  end

  describe "checkboxes" do
    let(:object) { double("object", role_ids: [1, 3]) }
    let(:field) do
      Superform::Rails::Field.new(:role_ids, parent: nil, object: object)
    end

    it "iterates over options yielding Choice objects" do
      choices = field.checkboxes([1, "Admin"], [2, "Editor"], [3, "Viewer"])
      values = choices.map { |c| [c.value, c.text] }
      expect(values).to eq([[1, "Admin"], [2, "Editor"], [3, "Viewer"]])
    end

    it "renders checkboxes with index-based ids" do
      html = ""
      field.checkboxes([1, "Admin"], [2, "Editor"], [3, "Viewer"]).each do |choice|
        html += render(choice.checkbox)
      end

      expect(html).to include('id="role_ids_0"')
      expect(html).to include('id="role_ids_1"')
      expect(html).to include('id="role_ids_2"')
      expect(html).to include('name="role_ids[]"')
    end

    it "checks checkboxes matching the field value" do
      html = ""
      field.checkboxes([1, "Admin"], [2, "Editor"], [3, "Viewer"]).each do |choice|
        html += render(choice.checkbox)
      end

      expect(html).to match(/<input[^>]*checked[^>]*value="1"/)
      expect(html).not_to match(/<input[^>]*checked[^>]*value="2"/)
      expect(html).to match(/<input[^>]*checked[^>]*value="3"/)
    end

    it "renders labels with matching for attributes" do
      html = ""
      field.checkboxes([1, "Admin"], [2, "Editor"]).each do |choice|
        html += render(choice.label { choice.text })
      end

      expect(html).to include('for="role_ids_0"')
      expect(html).to include('for="role_ids_1"')
    end
  end

  describe "is Enumerable" do
    let(:object) { double("object", status: "active") }
    let(:field) do
      Superform::Rails::Field.new(:status, parent: nil, object: object)
    end

    it "supports Enumerable methods like map" do
      texts = field.radios("active", "inactive").map(&:text)
      expect(texts).to eq(["active", "inactive"])
    end

    it "supports count" do
      expect(field.radios("a", "b", "c").count).to eq(3)
    end
  end
end
