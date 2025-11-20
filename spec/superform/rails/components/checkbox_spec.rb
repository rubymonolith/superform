# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Superform::Rails::Components::Checkbox, type: :view do
  describe 'boolean mode (backwards compatibility)' do
    let(:object) { double('object', featured: featured_value) }
    let(:featured_value) { false }
    let(:field) do
      Superform::Rails::Field.new(:featured, parent: nil, object: object)
    end
    let(:component) do
      described_class.new(field, attributes: attributes)
    end
    let(:attributes) { {} }

    subject { render(component) }

    it 'renders a hidden input with value 0' do
      expect(subject).to include('type="hidden"')
      expect(subject).to include('value="0"')
    end

    it 'renders a checkbox input with value 1' do
      expect(subject).to include('type="checkbox"')
      expect(subject).to include('value="1"')
    end

    it 'uses the correct name for both inputs' do
      expect(subject.scan(/name="featured"/).count).to eq(2)
    end

    it 'does not wrap inputs in a label' do
      expect(subject).not_to include('<label>')
    end

    it 'renders both inputs without wrapper' do
      expect(subject).to eq(
        '<input name="featured" type="hidden" value="0">' \
        '<input type="checkbox" value="1" id="featured" name="featured">'
      )
    end

    context 'when value is false' do
      let(:featured_value) { false }

      it 'does not check the checkbox' do
        expect(subject).not_to include('checked')
      end
    end

    context 'when value is true' do
      let(:featured_value) { true }

      it 'checks the checkbox' do
        expect(subject).to match(/<input[^>]*type="checkbox"[^>]*checked/)
      end
    end
  end

  describe 'array mode (multi-select)' do
    let(:object) { double('object', sushi: sushi_value) }
    let(:sushi_value) { [] }
    let(:field) do
      Superform::Rails::Field.new(:sushi, parent: nil, object: object)
    end
    let(:options) do
      [
        ['shirako', 'Shirako'],
        ['ankimo', 'Ankimo'],
        ['tsubugai', 'Tsubugai']
      ]
    end
    let(:component) do
      described_class.new(field, *options, attributes: attributes)
    end
    let(:attributes) { {} }

    subject { render(component) }

    it 'renders multiple checkbox inputs' do
      expect(subject.scan(/<input[^>]*type="checkbox"/).count).to eq(3)
    end

    it 'does not render hidden inputs in array mode' do
      expect(subject).not_to include('type="hidden"')
    end

    it 'renders checkboxes with correct values' do
      expect(subject).to include('value="shirako"')
      expect(subject).to include('value="ankimo"')
      expect(subject).to include('value="tsubugai"')
    end

    it 'renders unique IDs for each checkbox' do
      expect(subject).to include('id="sushi_shirako"')
      expect(subject).to include('id="sushi_ankimo"')
      expect(subject).to include('id="sushi_tsubugai"')
    end

    it 'uses array notation for all checkbox names' do
      expect(subject.scan(/name="sushi\[\]"/).count).to eq(3)
    end

    it 'wraps each checkbox in a label' do
      expect(subject.scan(/<label>/).count).to eq(3)
      expect(subject.scan(/<\/label>/).count).to eq(3)
    end

    it 'does not check any checkbox by default' do
      expect(subject).not_to include('checked')
    end

    it 'renders complete HTML structure' do
      expect(subject).to eq(
        '<label><input type="checkbox" id="sushi_shirako" name="sushi[]" value="shirako">Shirako</label>' \
        '<label><input type="checkbox" id="sushi_ankimo" name="sushi[]" value="ankimo">Ankimo</label>' \
        '<label><input type="checkbox" id="sushi_tsubugai" name="sushi[]" value="tsubugai">Tsubugai</label>'
      )
    end

    context 'with selected values' do
      let(:sushi_value) { ['ankimo', 'tsubugai'] }

      it 'checks the matching checkboxes' do
        expect(subject).to match(
          /<input[^>]*id="sushi_ankimo"[^>]*checked[^>]*>/
        )
        expect(subject).to match(
          /<input[^>]*id="sushi_tsubugai"[^>]*checked[^>]*>/
        )
      end

      it 'does not check other checkboxes' do
        expect(subject).not_to match(
          /<input[^>]*id="sushi_shirako"[^>]*checked[^>]*>/
        )
      end

      it 'renders complete HTML structure with checked state' do
        expect(subject).to eq(
          '<label><input type="checkbox" id="sushi_shirako" name="sushi[]" value="shirako">Shirako</label>' \
          '<label><input type="checkbox" id="sushi_ankimo" name="sushi[]" value="ankimo" checked>Ankimo</label>' \
          '<label><input type="checkbox" id="sushi_tsubugai" name="sushi[]" value="tsubugai" checked>Tsubugai</label>'
        )
      end
    end

    context 'with numeric values' do
      let(:object) { double('object', role_ids: role_ids_value) }
      let(:role_ids_value) { [2, 3] }
      let(:field) do
        Superform::Rails::Field.new(:role_ids, parent: nil, object: object)
      end
      let(:options) { [[1, 'Admin'], [2, 'Editor'], [3, 'Viewer']] }

      it 'checks the matching checkboxes with numeric comparison' do
        expect(subject).to match(
          /<input[^>]*id="role_ids_2"[^>]*checked[^>]*>/
        )
        expect(subject).to match(
          /<input[^>]*id="role_ids_3"[^>]*checked[^>]*>/
        )
      end
    end
  end

  describe 'using field helper method' do
    let(:form_field) do
      Superform::Rails::Field.new(:sushi, parent: nil, object: object)
    end
    let(:object) { double('object', sushi: []) }

    context 'with positional arguments (array mode)' do
      subject do
        render(
          form_field.checkbox(
            ['shirako', 'Shirako'],
            ['ankimo', 'Ankimo'],
            ['tsubugai', 'Tsubugai']
          )
        )
      end

      it 'renders checkboxes from positional args' do
        expect(subject).to include('value="shirako"')
        expect(subject).to include('value="ankimo"')
        expect(subject).to include('value="tsubugai"')
      end

      it 'uses array notation for names' do
        expect(subject.scan(/name="sushi\[\]"/).count).to eq(3)
      end
    end

    context 'with mixed format positional arguments' do
      let(:object) { double('object', preferences: []) }
      let(:form_field) do
        Superform::Rails::Field.new(:preferences, parent: nil, object: object)
      end

      subject do
        render(
          form_field.checkbox(
            [true, 'Email notifications'],
            [false, 'SMS notifications'],
            'Push notifications'
          )
        )
      end

      it 'renders checkboxes with array pairs using first as value' do
        expect(subject).to include('value="true"')
        expect(subject).to include('value="false"')
      end

      it 'renders checkboxes with array pairs using second as label' do
        expect(subject).to include('>Email notifications')
        expect(subject).to include('>SMS notifications')
      end

      it 'renders checkbox with single value for both value and label' do
        expect(subject).to include('value="Push notifications"')
        expect(subject).to include('>Push notifications')
      end
    end

    context 'without arguments (boolean mode)' do
      let(:object) { double('object', featured: false) }
      let(:form_field) do
        Superform::Rails::Field.new(:featured, parent: nil, object: object)
      end

      subject do
        render(form_field.checkbox)
      end

      it 'renders a boolean checkbox' do
        expect(subject).to include('type="checkbox"')
        expect(subject).to include('value="1"')
      end

      it 'renders a hidden field' do
        expect(subject).to include('type="hidden"')
        expect(subject).to include('value="0"')
      end

      it 'does not use array notation' do
        expect(subject).not_to include('name="featured[]"')
        expect(subject).to include('name="featured"')
      end
    end
  end

  describe 'with custom attributes' do
    let(:object) { double('object', sushi: []) }
    let(:field) do
      Superform::Rails::Field.new(:sushi, parent: nil, object: object)
    end
    let(:attributes) { { class: 'custom-checkbox', data: { controller: 'checkbox' } } }
    let(:component) do
      described_class.new(
        field,
        ['shirako', 'Shirako'],
        ['ankimo', 'Ankimo'],
        attributes: attributes
      )
    end

    subject { render(component) }

    it 'applies custom attributes to all checkboxes' do
      expect(subject).to include('class="custom-checkbox"')
      expect(subject).to include('data-controller="checkbox"')
      expect(subject.scan(/class="custom-checkbox"/).count).to eq(2)
    end
  end

  describe 'with block for custom rendering' do
    let(:object) { double('object', sushi: []) }
    let(:field) do
      Superform::Rails::Field.new(:sushi, parent: nil, object: object)
    end
    let(:component) do
      described_class.new(
        field,
        ['shirako', 'Shirako'],
        ['ankimo', 'Ankimo'],
        ['tsubugai', 'Tsubugai'],
        attributes: {}
      )
    end

    subject do
      render(component) do |checkbox|
        checkbox.option('shirako') { 'Shirako' }
        checkbox.option('ankimo') { 'Ankimo' }
      end
    end

    it 'renders custom checkboxes via block' do
      expect(subject).to include('value="shirako"')
      expect(subject).to include('value="ankimo"')
    end

    it 'does not render options from constructor' do
      expect(subject).not_to include('value="tsubugai"')
    end
  end

  describe 'with block but no constructor options' do
    let(:object) { double('object', features: []) }
    let(:field) do
      Superform::Rails::Field.new(:features, parent: nil, object: object)
    end
    let(:component) do
      described_class.new(field, attributes: {})
    end

    subject do
      render(component) do |checkbox|
        checkbox.option('dark_mode') { 'Dark Mode' }
        checkbox.option('notifications') { 'Notifications' }
      end
    end

    it 'renders checkboxes from block without constructor options' do
      expect(subject).to include('value="dark_mode"')
      expect(subject).to include('value="notifications"')
    end

    it 'wraps each checkbox in a label' do
      expect(subject.scan(/<label>/).count).to eq(2)
    end

    it 'uses array notation for names' do
      expect(subject.scan(/name="features\[\]"/).count).to eq(2)
    end
  end

  describe 'with ActiveRecord::Relation' do
    before do
      User.create!(first_name: 'Alice', email: 'alice@example.com')
      User.create!(first_name: 'Bob', email: 'bob@example.com')
      User.create!(first_name: 'Charlie', email: 'charlie@example.com')
    end

    after do
      User.delete_all
    end

    let(:object) { double('object', author_ids: author_ids_value) }
    let(:author_ids_value) { [] }
    let(:field) do
      Superform::Rails::Field.new(:author_ids, parent: nil, object: object)
    end
    let(:users_relation) { User.select(:id, :first_name) }

    context 'passed directly via field helper' do
      let(:form_field) do
        Superform::Rails::Field.new(:author_ids, parent: nil, object: object)
      end

      subject do
        # Pass relation directly without wrapping in array
        render(form_field.checkbox(users_relation))
      end

      it 'renders checkboxes from ActiveRecord relation' do
        expect(subject).to match(/<input[^>]*value="\d+"[^>]*>Alice/)
        expect(subject).to match(/<input[^>]*value="\d+"[^>]*>Bob/)
        expect(subject).to match(/<input[^>]*value="\d+"[^>]*>Charlie/)
      end

      it 'uses array notation for names' do
        expect(subject.scan(/name="author_ids\[\]"/).count).to eq(3)
      end

      it 'generates proper HTML structure with labels' do
        expect(subject).to include('<label>')
        expect(subject.scan(/<label>/).count).to eq(3)
      end

      context 'with selected values' do
        let(:alice) { User.find_by(first_name: 'Alice') }
        let(:charlie) { User.find_by(first_name: 'Charlie') }
        let(:author_ids_value) { [alice.id, charlie.id] }

        it 'checks the matching checkboxes' do
          expect(subject).to match(
            /<input[^>]*id="author_ids_#{alice.id}"[^>]*checked[^>]*>/
          )
          expect(subject).to match(
            /<input[^>]*id="author_ids_#{charlie.id}"[^>]*checked[^>]*>/
          )
        end

        it 'does not check other checkboxes' do
          bob = User.find_by(first_name: 'Bob')
          expect(subject).not_to match(
            /<input[^>]*id="author_ids_#{bob.id}"[^>]*checked[^>]*>/
          )
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
