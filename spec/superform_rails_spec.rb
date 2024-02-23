require 'action_view'
require 'active_model'
require 'ostruct'
require 'phlex'
require 'phlex-rails'
require 'phlex/testing/nokogiri'
require 'phlex/testing/rails/view_helper'
require 'phlex/testing/view_helper'

class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers
end

class Model
  include ActiveModel::Model
end

RSpec.describe Superform::Rails::Form do
  include Phlex::Testing::ViewHelper
  include Phlex::Testing::Rails::ViewHelper
  include Phlex::Testing::Nokogiri::FragmentHelper

  def instance(model:, **kwargs)
    described_class.new(model, **kwargs ).tap do |instance|
      allow(instance).to receive(:helpers) do
        double(
          'helpers',
          url_for: 'some_url',
          form_authenticity_token: 'xxxx'
        )
      end
    end
  end

  let(:method) { nil }
  let(:action) { '/submissions' }
  let(:persisted?) { false }
  let(:model) do
    Model.new.tap do |model|
      allow(model).to receive(:persisted?).and_return(persisted?)
    end
  end

  describe 'form' do
    subject(:form) do
      render(instance(model:, method:, action:))
    end

    context 'when @method missing and not persisted' do
      let(:persisted?) { false }
      it 'infers form method' do
        expect(form.css('form').attr('method').value).to be_eql('post')
      end

      it 'infers method field value' do
        expect(form.css('input[name=_method]').attr('value').value).to be_eql('post')
      end
    end

    context 'when @method missing and persisted' do
      let(:persisted?) { true }
      it 'infers form method' do
        expect(form.css('form').attr('method').value).to be_eql('post')
      end

      it 'infers method field value' do
        expect(form.css('input[name=_method]').attr('value').value).to be_eql('patch')
      end
    end

    context 'when @method provided' do
      let(:method) { :post }

      it 'has correct form method' do
        expect(form.css('form').attr('method').value).to be_eql('post')
      end

      it 'has correct method field value' do
        expect(form.css('input[name=_method]').attr('value').value).to be_eql('post')
      end
    end
  end
end