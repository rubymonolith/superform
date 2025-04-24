RSpec.describe Superform::Rails::Form do
  let(:model) { double('MockModel', model_name: double(param_key: 'mock_model')) }

  it 'creates a root namespace based on the active model' do
    expect(Superform::Namespace).to receive(:root).with('mock_model', any_args)

    described_class.new(model)
  end

  context 'override root namespace with an argument' do
    it 'creates a root namespace based on the namespace argument' do
      expect(Superform::Namespace).to receive(:root).with('user', any_args)

      described_class.new(model, namespace: 'user')
    end
  end
end
