module Superform
  module Rails
    module Components
      class Textarea < Field
        def view_template(&content)
          content ||= Proc.new { dom.value }
          textarea(**attributes, &content)
        end
      end
    end
  end
end