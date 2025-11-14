# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Superform::Rails::Components::Radio, type: :view do
  let(:object) { double('object', sushi: sushi_value) }
  let(:sushi_value) { nil }
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
    described_class.new(field, attributes: attributes, options: options)
  end
  let(:attributes) { {} }

  describe 'radio group with options' do
    subject { render(component) }

    it 'renders multiple radio inputs' do
      expect(subject.scan(/<input[^>]*type="radio"/).count).to eq(3)
    end

    it 'renders radio inputs with correct values' do
      expect(subject).to include('value="shirako"')
      expect(subject).to include('value="ankimo"')
      expect(subject).to include('value="tsubugai"')
    end

    it 'renders unique IDs for each radio button' do
      expect(subject).to include('id="sushi_shirako"')
      expect(subject).to include('id="sushi_ankimo"')
      expect(subject).to include('id="sushi_tsubugai"')
    end

    it 'uses the same name for all radio buttons' do
      expect(subject.scan(/name="sushi"/).count).to eq(3)
    end

    it 'does not check any radio by default' do
      expect(subject).not_to include('checked')
    end

    it 'renders complete HTML structure' do
      expect(subject).to eq(
        '<input name="sushi" type="radio" id="sushi_shirako" value="shirako">Shirako' \
        '<input name="sushi" type="radio" id="sushi_ankimo" value="ankimo">Ankimo' \
        '<input name="sushi" type="radio" id="sushi_tsubugai" value="tsubugai">Tsubugai'
      )
    end
  end

  describe 'with selected value' do
    let(:sushi_value) { 'ankimo' }

    subject { render(component) }

    it 'checks the matching radio button' do
      expect(subject).to match(
        /<input[^>]*id="sushi_ankimo"[^>]*checked[^>]*>/
      )
    end

    it 'does not check other radio buttons' do
      expect(subject).not_to match(
        /<input[^>]*id="sushi_shirako"[^>]*checked[^>]*>/
      )
      expect(subject).not_to match(
        /<input[^>]*id="sushi_tsubugai"[^>]*checked[^>]*>/
      )
    end

    it 'renders complete HTML structure with checked state' do
      expect(subject).to eq(
        '<input name="sushi" type="radio" id="sushi_shirako" value="shirako">Shirako' \
        '<input name="sushi" type="radio" id="sushi_ankimo" value="ankimo" checked>Ankimo' \
        '<input name="sushi" type="radio" id="sushi_tsubugai" value="tsubugai">Tsubugai'
      )
    end
  end

  describe 'with numeric value' do
    let(:object) { double('object', role_id: role_id_value) }
    let(:role_id_value) { 2 }
    let(:field) do
      Superform::Rails::Field.new(:role_id, parent: nil, object: object)
    end
    let(:options) { [[1, 'Admin'], [2, 'Editor'], [3, 'Viewer']] }

    subject { render(component) }

    it 'checks the matching radio button with numeric comparison' do
      expect(subject).to match(
        /<input[^>]*id="role_id_2"[^>]*checked[^>]*>/
      )
    end
  end

  describe 'using field helper method' do
    let(:form_field) do
      Superform::Rails::Field.new(:sushi, parent: nil, object: object)
    end

    context 'with positional arguments' do
      subject do
        render(
          form_field.radio(
            ['shirako', 'Shirako'],
            ['ankimo', 'Ankimo'],
            ['tsubugai', 'Tsubugai']
          )
        )
      end

      it 'renders radio buttons from positional args' do
        expect(subject).to include('value="shirako"')
        expect(subject).to include('value="ankimo"')
        expect(subject).to include('value="tsubugai"')
      end
    end

    context 'with options keyword argument' do
      subject do
        render(
          form_field.radio(
            options: [
              ['shirako', 'Shirako'],
              ['ankimo', 'Ankimo'],
              ['tsubugai', 'Tsubugai']
            ]
          )
        )
      end

      it 'renders radio buttons from options kwarg' do
        expect(subject).to include('value="shirako"')
        expect(subject).to include('value="ankimo"')
        expect(subject).to include('value="tsubugai"')
      end
    end

    context 'with single value (legacy API)' do
      subject do
        render(form_field.radio('shirako', id: 'custom_id'))
      end

      it 'renders a single radio input' do
        expect(subject).to include('type="radio"')
        expect(subject).to include('value="shirako"')
        expect(subject).to include('id="custom_id"')
      end

      it 'renders only one radio button' do
        expect(subject.scan(/<input/).count).to eq(1)
      end
    end
  end

  describe 'with custom attributes' do
    let(:attributes) { { class: 'custom-radio', data: { controller: 'radio' } } }

    subject { render(component) }

    it 'applies custom attributes to all radio buttons' do
      expect(subject).to include('class="custom-radio"')
      expect(subject).to include('data-controller="radio"')
      expect(subject.scan(/class="custom-radio"/).count).to eq(3)
    end
  end

  describe 'with block for custom rendering' do
    subject do
      render(component) do |radio|
        radio.button('shirako') { 'Shirako' }
        radio.button('ankimo') { 'Ankimo' }
      end
    end

    it 'renders custom radio buttons via block' do
      expect(subject).to include('value="shirako"')
      expect(subject).to include('value="ankimo"')
    end

    it 'does not render options from constructor' do
      expect(subject).not_to include('value="tsubugai"')
    end
  end

  describe '#button method' do
    let(:component) do
      described_class.new(field, attributes: {}, options: [])
    end

    context 'with simple value and label' do
      subject do
        render(component) do |radio|
          radio.button('omakase') { 'Chef\'s Choice' }
        end
      end

      it 'renders radio button with value and label' do
        expect(subject).to include('value="omakase"')
        expect(subject).to include('>Chef&#39;s Choice')
      end

      it 'generates ID from field name and value' do
        expect(subject).to include('id="sushi_omakase"')
      end
    end
  end

  describe 'inside a collection (with parent field)' do
    let(:orders_field) do
      orders_object = double('orders', orders: [{}, {}])
      Superform::Rails::Field.new(
        :orders,
        parent: nil,
        object: orders_object,
        value: [{}, {}]
      )
    end
    let(:order_collection) { orders_field.collection }
    let(:order_field) { order_collection.field }
    let(:sushi_field) do
      sushi_object = double('order', sushi: nil)
      Superform::Rails::Field.new(:sushi, parent: order_field, object: sushi_object)
    end
    let(:component) do
      described_class.new(
        sushi_field,
        attributes: attributes,
        options: options
      )
    end

    subject { render(component) }

    it 'uses collection notation for field name' do
      # When parent is a Field (from collection), it should use orders[][]
      # First [] is the collection index, second [] is the field
      expect(subject).to include('name="orders[][]"')
    end

    it 'does not include the sushi key in the name' do
      # The sushi key is excluded when parent is a Field
      expect(subject).not_to include('name="orders[][][sushi]"')
    end

    it 'generates unique IDs including collection index' do
      expect(subject).to include('id="orders_1_sushi_shirako"')
      expect(subject).to include('id="orders_1_sushi_ankimo"')
      expect(subject).to include('id="orders_1_sushi_tsubugai"')
    end

    it 'renders all radio buttons correctly' do
      expect(subject.scan(/<input[^>]*type="radio"/).count).to eq(3)
      expect(subject).to include('value="shirako"')
      expect(subject).to include('value="ankimo"')
      expect(subject).to include('value="tsubugai"')
    end
  end

  describe 'with ActiveRecord::Relation' do
    before do
      User.create!(first_name: 'Alice', email: 'alice@example.com')
      User.create!(first_name: 'Bob', email: 'bob@example.com')
    end

    after do
      User.delete_all
    end

    let(:object) { double('object', author_id: author_id_value) }
    let(:author_id_value) { nil }
    let(:field) do
      Superform::Rails::Field.new(:author_id, parent: nil, object: object)
    end
    let(:users_relation) { User.select(:id, :first_name) }
    let(:component) do
      described_class.new(field, attributes: attributes, options: [users_relation])
    end

    subject { render(component) }

    it 'renders radio buttons from ActiveRecord relation' do
      # OptionMapper extracts id as value and joins other attributes as label
      expect(subject).to match(/<input[^>]*value="\d+"[^>]*>Alice/)
      expect(subject).to match(/<input[^>]*value="\d+"[^>]*>Bob/)
    end

    it 'generates IDs from field name and record ID' do
      alice = User.find_by(first_name: 'Alice')
      expect(subject).to include("id=\"author_id_#{alice.id}\"")
    end
  end
end
# rubocop:enable Metrics/BlockLength
