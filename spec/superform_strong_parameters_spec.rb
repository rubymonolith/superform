# frozen_string_literal: true

require 'spec_helper'
require 'action_controller'

class DummyController < ActionController::Base
  include Superform::Rails::StrongParameters
end

class Form < ApplicationForm
  def template
    render field(:title).input
    render field(:email).input
    namespace(:name) do |name|
      div do
        render name.field(:first).input
        render name.field(:last).input
      end
    end
  end
end


RSpec.describe DummyController, type: :controller do

  before do
    stub_form(form)
  end

  subject(:ctrl) do
    DummyController.new
  end

  let(:model_class) do
    create_model do |model|
      model.attribute :title
      model.attribute :email
      model.attribute :name, default: OpenStruct.new(first: 'Default', last: 'Value')
    end
  end

  let(:form) do
    Form.new(model_class.new)
  end

  describe 'param handling + rendering' do
    # ensure we eagerly evaluate subject since some tests are against form
    subject!(:model) { ctrl.send(:assign, params, to: form) }

    context 'with expected params' do
      let(:params) do
        ActionController::Parameters.new(
          {
            title: 'dev',
            email: 'super@form.com',
            name: { first: 'William', last: 'Bills' },
          }
        )
      end

      it 'renders all fields' do
        expect(render(form))
          .to render_nodes(
            'input[name="model[name][first]"]',
            'input[name="model[name][last]"]',
            'input[name="model[title]"]',
            'input[name="model[email]"]'
          )
      end

      it 'assigns' do
        expect(model)
          .to have_attributes(
            name: instance_of(OpenStruct),
            email: instance_of(String),
            title: instance_of(String)
          )
      end
    end

    context 'with extra params' do
      let(:params) do
        ActionController::Parameters.new(
          {
            phone: '1231231234',
            domain: 'someurl',
            number: 123,
            title: 'ceo',
            name:
              {
                first_name: 'Hello',
                last_name: 'There'
              },
            email: 'there@blah.com'
          }
        )
      end

      it 'renders all fields' do
        expect(render(form))
          .to render_nodes(
            'input[name="model[name][first]"]',
            'input[name="model[name][last]"]',
            'input[name="model[title]"]',
            'input[name="model[email]"]'
          )
      end

      it 'assigns' do
        expect(model).to have_attributes(
          name: instance_of(OpenStruct),
          email: be_a(String),
          title: be_a(String)
        )
      end
    end

    context 'with no params' do
      let(:params) { ActionController::Parameters.new }
      it 'renders all fields' do
        expect(render(form))
          .to render_nodes(
            'input[name="model[name][first]"]',
            'input[name="model[name][last]"]',
            'input[name="model[title]"]',
            'input[name="model[email]"]'
          )
      end

      it 'assigns' do
        expect(model).to have_attributes(
          name: instance_of(OpenStruct),
          email: be_nil,
          title: be_nil
        )
      end
    end
  end
end
