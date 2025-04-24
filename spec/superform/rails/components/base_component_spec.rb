RSpec.describe Superform::Rails::Components::BaseComponent do
  class CustomComponent < described_class
    def view_template
      input(**attributes)
    end
  end

  subject(:component) { CustomComponent.new(field, type: 'text') }

  let(:field) { described_class.new(:foo, parent: nil, object:) }
  let(:object) { double('Foo', bar: 'baz') }

  it 'reads the attributes' do
    expect(component).to receive(:input).with(type: 'text')

    component.call
  end
end
