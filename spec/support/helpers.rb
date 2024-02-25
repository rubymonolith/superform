# frozen_string_literal: true

module Superform
  module Testing
    module Helpers
      def stub_form(form)
        allow(form).to receive(:helpers) do
          double(
            'helpers',
            url_for: 'some_url',
            form_authenticity_token: 'xxxx'
          )
        end
      end

      def create_model
        Class.new do
          include ActiveModel::Model
          include ActiveModel::Attributes

          def self.name
            'Model'
          end

          yield self if block_given?
        end
      end
    end
  end
end
