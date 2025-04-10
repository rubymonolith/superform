RSpec.describe Superform::Rails::Form::Field do
  let(:field) { described_class.new(:foo, parent: nil, object:) }
  let(:object) { double('Foo', bar: 'baz') }

  let(:attributes) do
    { class: %[a b], role: 'element' }
  end
  let(:template) { proc { 'baz' } }

  it { expect(field).to be_a(Superform::Field) }

  { input: 'InputComponent', label: 'LabelComponent', button: 'ButtonComponent',
    checkbox: 'CheckboxComponent', textarea: 'TextareaComponent' }.each do |method, klass|
    describe method.to_s do
      it "delegates to #{klass}" do
        component_class = Superform::Rails::Components.const_get(klass)

        expect(component_class).to receive(:new).with(field, **attributes, &template)

        field.send(method, **attributes, &template)
      end
    end
  end

  describe 'select' do
    it 'delegates to SelectField component' do
      expect(Superform::Rails::Components::SelectField).to receive(:new).with(
        field, collection: [], **attributes, &template
      )

      field.select(**attributes, &template)
    end
  end
end
