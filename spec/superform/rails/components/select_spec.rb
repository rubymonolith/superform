RSpec.describe Superform::Rails::Components::Select, type: :view do
  let(:object) { double('object', role_ids: role_ids_value) }
  let(:role_ids_value) { nil }
  let(:field) do
    Superform::Rails::Field.new(:role_ids, parent: nil, object: object)
  end
  let(:options) { [[1, 'Admin'], [2, 'Editor'], [3, 'Viewer']] }
  let(:component) do
    described_class.new(field, options:, **attributes)
  end
  let(:attributes) { {} }

  describe 'basic select' do
    subject { render(component) }

    it 'renders select with options' do
      expect(subject).to eq(
        '<select id="role_ids" name="role_ids">' \
        '<option value="1">Admin</option>' \
        '<option value="2">Editor</option>' \
        '<option value="3">Viewer</option>' \
        '</select>'
      )
    end
  end

  describe 'with selected value' do
    let(:role_ids_value) { 2 }

    subject { render(component) }

    it 'marks the matching option as selected' do
      expect(subject).to eq(
        '<select id="role_ids" name="role_ids">' \
        '<option value="1">Admin</option>' \
        '<option selected value="2">Editor</option>' \
        '<option value="3">Viewer</option>' \
        '</select>'
      )
    end
  end

  describe 'with multiple: true' do
    let(:component) do
      described_class.new(
        field,
        **attributes,
        options:,
        multiple: true
      )
    end

    subject { render(component) }

    it 'renders hidden input, appends [] to name, and adds multiple attribute' do
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

  describe 'with multiple: true and selected array values' do
    let(:role_ids_value) { [1, 3] }
    let(:component) do
      described_class.new(
        field,
        **attributes,
        options:,
        multiple: true
      )
    end

    subject { render(component) }

    it 'marks all matching options as selected' do
      expect(subject).to eq(
        '<input type="hidden" name="role_ids[]" value="">' \
        '<select id="role_ids" name="role_ids[]" multiple>' \
        '<option selected value="1">Admin</option>' \
        '<option value="2">Editor</option>' \
        '<option selected value="3">Viewer</option>' \
        '</select>'
      )
    end
  end

  describe 'with blank option (nil)' do
    let(:component) do
      described_class.new(
        field,
        **attributes,
        options: [nil, *options]
      )
    end

    subject { render(component) }

    it 'renders a selected blank option before other options' do
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
        **attributes,
        options:,
        multiple: true
      )
    end

    subject { render(component) }

    it 'does not append extra [] when parent is a Field' do
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

  describe 'field helper method' do
    let(:form_field) do
      Superform::Rails::Field.new(:role_ids, parent: nil, object: object)
    end

    it 'accepts positional arguments' do
      html = render(form_field.select([1, 'Admin'], [2, 'Editor'], [3, 'Viewer']))
      expect(html).to include('>Admin</option>')
      expect(html).to include('>Editor</option>')
      expect(html).to include('>Viewer</option>')
    end

    it 'accepts multiple: true keyword' do
      html = render(form_field.select([1, 'Admin'], [2, 'Editor'], multiple: true))
      expect(html).to include('multiple')
      expect(html).to include('name="role_ids[]"')
    end
  end

  describe '#blank_option' do
    let(:component) do
      described_class.new(field, options: [], **attributes)
    end

    it 'renders selected when field value is nil' do
      output = render(component, &:blank_option)
      expect(output).to match(%r{<option[^>]*selected[^>]*></option>})
    end

    it 'renders unselected when field has a value' do
      object = double('object', role_ids: 1)
      field = Superform::Rails::Field.new(:role_ids, parent: nil, object: object)
      component = described_class.new(field, options: [])
      output = render(component, &:blank_option)
      expect(output).not_to match(/<option[^>]*selected/)
    end
  end

  describe 'with hash options' do
    let(:component) do
      described_class.new(field, options: [{ 1 => 'Admin', 2 => 'Editor', 3 => 'Viewer' }])
    end

    subject { render(component) }

    it 'renders select with options from hash' do
      expect(subject).to eq(
        '<select id="role_ids" name="role_ids">' \
        '<option value="1">Admin</option>' \
        '<option value="2">Editor</option>' \
        '<option value="3">Viewer</option>' \
        '</select>'
      )
    end
  end

  describe 'with ActiveRecord::Relation' do
    before do
      User.create!(first_name: 'Alice', email: 'alice@example.com')
      User.create!(first_name: 'Bob', email: 'bob@example.com')
    end

    after { User.delete_all }

    it 'renders options from ActiveRecord relation' do
      users_relation = User.select(:id, :first_name)
      component = described_class.new(field, options: [users_relation])
      html = render(component)
      expect(html).to match(/<option value="\d+">Alice<\/option>/)
      expect(html).to match(/<option value="\d+">Bob<\/option>/)
    end
  end
end
