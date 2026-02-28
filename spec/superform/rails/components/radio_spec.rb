RSpec.describe Superform::Rails::Components::Radio, type: :view do
  describe 'single radio' do
    let(:object) { double('object', gender: "male") }
    let(:field) do
      Superform::Rails::Field.new(:gender, parent: nil, object: object)
    end

    it 'renders a checked radio when value matches' do
      html = render(field.radio("male"))
      expect(html).to include('type="radio"')
      expect(html).to include('name="gender"')
      expect(html).to include('value="male"')
      expect(html).to include('checked')
    end

    it 'renders an unchecked radio when value does not match' do
      html = render(field.radio("female"))
      expect(html).to include('value="female"')
      expect(html).not_to include('checked')
    end

    it 'accepts custom attributes' do
      html = render(field.radio("male", class: "radio-input"))
      expect(html).to include('class="radio-input"')
    end
  end

  describe 'radio collection' do
    let(:object) { double('object', status: "active") }
    let(:field) do
      Superform::Rails::Field.new(:status, parent: nil, object: object)
    end

    it 'returns an enumerable' do
      collection = field.radio("active", "inactive", "pending")
      expect(collection).to respond_to(:each)
    end

    it 'yields options with value, label, and radio' do
      options = field.radio(["active", "Active"], ["inactive", "Inactive"]).to_a
      expect(options.length).to eq(2)
      expect(options.first.value).to eq("active")
      expect(options.first.label).to eq("Active")
      expect(options.first).to respond_to(:radio)
    end

    it 'renders radios with correct checked state' do
      html = ""
      field.radio(["active", "Active"], ["inactive", "Inactive"], ["pending", "Pending"]).each do |status|
        html += render(status.radio)
      end

      expect(html.scan(/type="radio"/).count).to eq(3)
      expect(html.scan(/name="status"/).count).to eq(3)
      expect(html.scan(/checked/).count).to eq(1)
      expect(html).to match(/<input[^>]*value="active"[^>]*checked/)
      expect(html).not_to match(/<input[^>]*value="inactive"[^>]*checked/)
      expect(html).not_to match(/<input[^>]*value="pending"[^>]*checked/)
    end

    it 'generates unique IDs for each radio' do
      html = ""
      field.radio("active", "inactive").each do |status|
        html += render(status.radio)
      end

      expect(html).to include('id="status_1"')
      expect(html).to include('id="status_2"')
    end

    it 'works with the label pattern from the docs' do
      html = ""
      field.radio(["active", "Active"], ["inactive", "Inactive"]).each do |status|
        # Simulating: label { status.radio; whitespace; plain status.value.humanize }
        html += render(status.radio)
      end

      expect(html).to include('value="active"')
      expect(html).to include('value="inactive"')
      expect(html.scan(/checked/).count).to eq(1)
    end

    it 'works with single-value options (value used as label)' do
      options = field.radio("active", "inactive").to_a
      expect(options.first.value).to eq("active")
      expect(options.first.label).to eq("active")
    end
  end
end
