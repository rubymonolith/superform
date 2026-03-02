RSpec.describe Superform::Rails::Components::Checkbox, type: :view do
  describe 'boolean mode' do
    let(:object) { double('object', featured: featured_value) }
    let(:featured_value) { false }
    let(:field) do
      Superform::Rails::Field.new(:featured, parent: nil, object: object)
    end
    let(:component) { described_class.new(field) }

    subject { render(component) }

    it 'renders hidden input and checkbox with boolean values' do
      expect(subject).to eq(
        '<input name="featured" type="hidden" value="0">' \
        '<input type="checkbox" value="1" id="featured" name="featured">'
      )
    end

    context 'when checked' do
      let(:featured_value) { true }

      it 'renders with checked attribute' do
        expect(subject).to match(/<input[^>]*type="checkbox"[^>]*checked/)
      end
    end

    context 'when unchecked' do
      let(:featured_value) { false }

      it 'renders without checked attribute' do
        expect(subject).not_to include('checked')
      end
    end
  end

  describe 'collection mode' do
    let(:object) { double('object', role_ids: [1, 3]) }
    let(:field) do
      Superform::Rails::Field.new(:role_ids, parent: nil, object: object)
    end

    it 'renders checked checkboxes for each value in the collection' do
      html = ""
      field.collection.each do |role|
        html += render(role.checkbox)
      end

      expect(html).to include('value="1"')
      expect(html).to include('value="3"')
      expect(html).to include('name="role_ids[]"')
      expect(html).not_to include('type="hidden"')
      expect(html.scan(/checked/).count).to eq(2)
    end
  end

  describe 'all-options mode' do
    let(:object) { double('object', role_ids: [1, 3]) }
    let(:field) do
      Superform::Rails::Field.new(:role_ids, parent: nil, object: object)
    end

    it 'checks selected values and leaves others unchecked' do
      all_roles = [[1, "Admin"], [2, "Editor"], [3, "Viewer"]]
      html = ""
      all_roles.each do |id, _name|
        html += render(described_class.new(field, value: id))
      end

      expect(html).to include('name="role_ids[]"')
      expect(html).not_to include('type="hidden"')
      # Only 1 and 3 are checked
      expect(html.scan(/checked/).count).to eq(2)
      expect(html).to match(/<input[^>]*checked[^>]*value="1"/)
      expect(html).to match(/<input[^>]*checked[^>]*value="3"/)
      expect(html).not_to match(/<input[^>]*checked[^>]*value="2"/)
    end

    it 'renders unique ids per value' do
      all_roles = [[1, "Admin"], [2, "Editor"], [3, "Viewer"]]
      html = ""
      all_roles.each do |id, _name|
        html += render(described_class.new(field, value: id))
      end

      expect(html).to include('id="role_ids_1"')
      expect(html).to include('id="role_ids_2"')
      expect(html).to include('id="role_ids_3"')
    end

    it 'works through the field helper' do
      html = render(field.checkbox(value: 1))
      expect(html).to include('id="role_ids_1"')
      expect(html).to include('name="role_ids[]"')
      expect(html).to include('checked')

      html = render(field.checkbox(value: 2))
      expect(html).to include('id="role_ids_2"')
      expect(html).to include('name="role_ids[]"')
      expect(html).not_to include('checked')
    end

    it 'supports explicit index: for id generation' do
      html = render(field.checkbox(value: 1, index: 0))
      expect(html).to include('id="role_ids_0"')
      expect(html).to include('value="1"')
    end
  end
end
