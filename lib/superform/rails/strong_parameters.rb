module Superform
  module Rails
    module StrongParameters
      protected
        # Assigns params to the form and returns the model.
        def assign(params, to:)
          form = to
          # TODO: Figure out how to render this in a way that doesn't concat a string; just throw everything away.
          render_to_string form
          form.assign params
          form.model
        end
    end
  end
end
