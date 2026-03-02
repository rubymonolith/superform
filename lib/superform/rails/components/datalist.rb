module Superform
  module Rails
    module Components
      class Datalist < Field
        def initialize(field, options: [], **attributes)
          super(field, **attributes)
          @options = options
        end

        def view_template(&block)
          datalist_id = DOM.join(dom.id, "datalist")
          input(list: datalist_id, **attributes)
          datalist(id: datalist_id) do
            if block
              yield self
            else
              options(*@options)
            end
          end
        end

        def options(*collection)
          Choices::Mapper.new(collection).each do |value, text|
            if value == text
              option(value: value)
            else
              option(value: value) { text }
            end
          end
        end
      end
    end
  end
end
