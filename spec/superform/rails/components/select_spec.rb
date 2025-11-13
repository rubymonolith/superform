# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Superform::Rails::Components::Select, type: :view do
  let(:object) { double('object', role_ids: role_ids_value) }
  let(:role_ids_value) { nil }
  let(:field) do
    Superform::Rails::Field.new(:role_ids, parent: nil, object: object)
  end
  let(:options) { [[1, 'Admin'], [2, 'Editor'], [3, 'Viewer']] }
  let(:component) do
    described_class.new(field, attributes: attributes, options: options)
  end
  let(:attributes) { {} }

  describe 'basic select' do
    subject { render(component) }

    it 'renders a select element' do
      expect(subject).to include('<select')
    end

    it 'renders options from collection' do
      expect(subject).to include('>Admin</option>')
      expect(subject).to include('>Editor</option>')
      expect(subject).to include('>Viewer</option>')
    end

    it 'includes the field name' do
      expect(subject).to include('name="role_ids"')
    end

    it 'does not include multiple attribute' do
      expect(subject).not_to include('multiple')
    end

    it 'renders complete HTML structure' do
      expect(subject).to eq(
        '<select id="role_ids" name="role_ids">' \
        '<option value="1">Admin</option>' \
        '<option value="2">Editor</option>' \
        '<option value="3">Viewer</option>' \
        '</select>'
      )
    end
  end

  describe 'with multiple: true' do
    let(:component) do
      described_class.new(
        field,
        attributes: attributes,
        options: options,
        multiple: true
      )
    end

    subject { render(component) }

    it 'includes multiple attribute' do
      expect(subject).to include('multiple')
    end

    it 'appends [] to field name' do
      expect(subject).to include('name="role_ids[]"')
    end

    it 'renders hidden input before select' do
      expect(subject).to match(
        /<input type="hidden" name="role_ids\[\]" value="">.*<select/m
      )
    end

    it 'renders hidden input with empty value' do
      expect(subject).to include('type="hidden" name="role_ids[]" value=""')
    end

    it 'renders complete HTML structure with hidden input' do
      expect(subject).to eq(
        '<input type="hidden" name="role_ids[]" value="">' \
        '<select id="role_ids" name="role_ids[]" multiple>' \
        '<option value="1">Admin</option>' \
        '<option value="2">Editor</option>' \
        '<option value="3">Viewer</option>' \
        '</select>'
      )
    end
  end

  describe 'with include_blank: true' do
    let(:component) do
      described_class.new(
        field,
        attributes: attributes,
        options: options,
        include_blank: true
      )
    end

    subject { render(component) }

    it 'renders a blank option' do
      expect(subject).to match(%r{<option[^>]*selected[^>]*></option>})
    end

    it 'renders blank option before collection options' do
      expect(subject).to match(
        %r{<option[^>]*selected[^>]*></option>.*>Admin<}m
      )
    end

    it 'renders complete HTML structure with blank option' do
      expect(subject).to eq(
        '<select id="role_ids" name="role_ids">' \
        '<option selected></option>' \
        '<option value="1">Admin</option>' \
        '<option value="2">Editor</option>' \
        '<option value="3">Viewer</option>' \
        '</select>'
      )
    end
  end

  describe 'with multiple: true inside a collection' do
    let(:users_field) do
      users_object = double('users', users: [{}, {}])
      Superform::Rails::Field.new(
        :users,
        parent: nil,
        object: users_object,
        value: [{}, {}]
      )
    end
    let(:user_collection) { users_field.collection }
    let(:user_field) { user_collection.field }
    let(:role_ids_field) do
      role_object = double('user', role_ids: nil)
      Superform::Rails::Field.new(:role_ids, parent: user_field, object: role_object)
    end
    let(:component) do
      described_class.new(
        role_ids_field,
        attributes: attributes,
        options: options,
        multiple: true
      )
    end

    subject { render(component) }

    it 'does not append extra [] when parent is a Field' do
      # The field name should be users[][] not users[][][]
      # because role_ids key is excluded when parent is a Field
      expect(subject).to include('name="users[][]"')
      expect(subject).not_to include('name="users[][][]"')
    end

    it 'still includes multiple attribute' do
      expect(subject).to include('multiple')
    end

    it 'renders hidden input with correct name' do
      expect(subject).to include('type="hidden" name="users[][]" value=""')
    end

    it 'renders complete HTML structure without extra brackets' do
      expect(subject).to eq(
        '<input type="hidden" name="users[][]" value="">' \
        '<select id="users_1_role_ids" name="users[][]" multiple>' \
        '<option value="1">Admin</option>' \
        '<option value="2">Editor</option>' \
        '<option value="3">Viewer</option>' \
        '</select>'
      )
    end
  end

  describe 'with both multiple and include_blank' do
    let(:component) do
      described_class.new(
        field,
        attributes: attributes,
        options: options,
        multiple: true,
        include_blank: true
      )
    end

    subject { render(component) }

    it 'renders both features correctly' do
      expect(subject).to include('multiple')
      expect(subject).to include('name="role_ids[]"')
      expect(subject).to match(%r{<option[^>]*selected[^>]*></option>})
    end
  end

  describe 'using field helper method' do
    let(:form_field) do
      Superform::Rails::Field.new(:role_ids, parent: nil, object: object)
    end

    context 'with positional collection arguments' do
      subject do
        render(form_field.select([1, 'Admin'], [2, 'Editor'], [3, 'Viewer']))
      end

      it 'renders select with options from positional args' do
        expect(subject).to include('>Admin</option>')
        expect(subject).to include('>Editor</option>')
        expect(subject).to include('>Viewer</option>')
      end
    end

    context 'with options keyword argument' do
      subject do
        render(
          form_field.select(
            options: [[1, 'Admin'], [2, 'Editor'], [3, 'Viewer']]
          )
        )
      end

      it 'renders select with options from options kwarg' do
        expect(subject).to include('>Admin</option>')
        expect(subject).to include('>Editor</option>')
        expect(subject).to include('>Viewer</option>')
      end
    end

    context 'with multiple: true keyword argument' do
      subject do
        render(
          form_field.select(
            options: [[1, 'Admin'], [2, 'Editor']],
            multiple: true
          )
        )
      end

      it 'renders multiple select with options kwarg' do
        expect(subject).to include('multiple')
        expect(subject).to include('name="role_ids[]"')
        expect(subject).to include('>Admin</option>')
        expect(subject).to include('>Editor</option>')
      end
    end
  end

  describe '#blank_option' do
    let(:component) do
      described_class.new(field, attributes: attributes, options: [])
    end

    context 'when field value is nil' do
      let(:role_ids_value) { nil }

      it 'renders selected blank option' do
        output = render(component, &:blank_option)
        expect(output).to match(%r{<option[^>]*selected[^>]*></option>})
      end
    end

    context 'when field has a value' do
      let(:role_ids_value) { 1 }

      it 'renders unselected blank option' do
        output = render(component, &:blank_option)
        expect(output).not_to match(/<option[^>]*selected/)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
