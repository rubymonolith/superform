module Superform
  module Rails
    module Components
      class Radios < Base
        def initialize(field, options: [], **attributes)
          super(field, **attributes)
          @options = options
        end

        def view_template(&block)
          choices.each do |choice|
            if block
              yield choice
            else
              label(for: DOM.join(dom.id, choice.index)) do
                render choice.build_input
                whitespace
                plain choice.text
              end
            end
          end
        end

        private

        def choices
          Choices::Mapper.new(@options).each_with_index.map do |(value, text), index|
            Choices::Choice.new(component: self, field: @field, value:, text:, index:, type: :radio)
          end
        end

        def field_attributes
          {}
        end
      end
    end
  end
end
