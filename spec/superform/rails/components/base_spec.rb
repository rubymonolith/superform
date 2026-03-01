RSpec.describe Superform::Rails::Components::Base do
  let(:object) { double('object', name: "Test") }
  let(:field) { Superform::Rails::Field.new(:name, parent: nil, object: object) }

  describe 'new kwargs style' do
    it 'accepts HTML attributes as kwargs' do
      component = described_class.new(field, class: "form-input", id: "custom")
      attrs = component.send(:attributes)
      expect(attrs[:class]).to eq("form-input")
      expect(attrs[:id]).to eq("custom")
    end
  end

  describe 'legacy attributes: style' do
    it 'accepts HTML attributes via attributes keyword with deprecation warning' do
      component = nil
      expect {
        component = described_class.new(field, attributes: { class: "form-input", id: "custom" })
      }.to output(/DEPRECATION/).to_stderr
      attrs = component.send(:attributes)
      expect(attrs[:class]).to eq("form-input")
      expect(attrs[:id]).to eq("custom")
    end
  end

  describe 'mixed style' do
    it 'merges attributes: keyword with kwargs' do
      component = nil
      expect {
        component = described_class.new(field, attributes: { class: "form-input" }, id: "custom")
      }.to output(/DEPRECATION/).to_stderr
      attrs = component.send(:attributes)
      expect(attrs[:class]).to eq("form-input")
      expect(attrs[:id]).to eq("custom")
    end
  end
end
