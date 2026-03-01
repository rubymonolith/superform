module Superform
  module Rails
    module HTML5
      class ValidationAttributes
        attr_reader :object, :key

        def initialize(object, key)
          @object = object
          @key = key
        end

        def to_h
          return {} unless object.class.respond_to?(:validators_on)

          attrs = {}
          validators = object.class.validators_on(key)

          validators.each do |v|
            next if conditional?(v)

            case v
            when ActiveRecord::Validations::PresenceValidator
              attrs[:required] = true
            when ActiveModel::Validations::LengthValidator
              merge_length!(attrs, v.options)
            when ActiveModel::Validations::NumericalityValidator
              merge_numericality!(attrs, v.options)
            end
          end

          attrs
        end

        private

        def conditional?(validator)
          validator.options.key?(:if) ||
            validator.options.key?(:unless) ||
            validator.options.key?(:on)
        end

        def merge_length!(attrs, opts)
          if opts[:is]
            attrs[:minlength] = opts[:is]
            attrs[:maxlength] = opts[:is]
          else
            attrs[:minlength] = opts[:minimum] || opts[:in]&.min if opts[:minimum] || opts[:in]
            attrs[:maxlength] = opts[:maximum] || opts[:in]&.max if opts[:maximum] || opts[:in]
          end
        end

        def merge_numericality!(attrs, opts)
          attrs[:min] = opts[:greater_than_or_equal_to] if opts.key?(:greater_than_or_equal_to)
          attrs[:max] = opts[:less_than_or_equal_to] if opts.key?(:less_than_or_equal_to)
          attrs[:step] = 1 if opts[:only_integer]
        end
      end
    end
  end
end
