module Superform
  module Rails
    module StrongParameters
      protected
      # Assigns permitted params to the given form and returns the model.
      # Usage in a controller when you want to build/validate without saving:
      #
      # def preview
      #   @post = Post.new
      #   post = permit PostForm.new(@post)
      #   # post now has attributes from params, but is not persisted
      #   render :preview
      # end
      def permit(form)
        form_params = params.require(form.key)
        assign(form_params, to: form).model
      end

      # Saves the form's underlying model after assigning permitted params.
      # Typical Rails controller usage (create):
      #
      # def create
      #   @post = Post.new
      #   if save PostForm.new(@post)
      #     redirect_to @post
      #   else
      #     render :new, status: :unprocessable_entity
      #   end
      # end
      #
      # Typical Rails controller usage (update):
      #
      # def update
      #   @post = Post.find(params[:id])
      #   if save PostForm.new(@post)
      #     redirect_to @post
      #   else
      #     render :edit, status: :unprocessable_entity
      #   end
      # end
      def save(form)
        permit(form).save
      end

      # Bang version that raises on validation failure.
      # Useful when you prefer exceptions or are in a transaction:
      #
      # def create
      #   @post = Post.new
      #   save! PostForm.new(@post)
      #   redirect_to @post
      # rescue ActiveRecord::RecordInvalid
      #   render :new, status: :unprocessable_entity
      # end
      def save!(form)
        permit(form).save!
      end

      # Assigns params to the form and returns the form.
      def assign(params, to:)
        to.tap do |form|
          # This output of this string goes nowhere since it likely
          # won't be used. I'm not sure if I'm right about this though,
          # If I'm wrong, then I think I need to encapsulate this module
          # into a class that can store the rendered HTML that can be
          # rendered later.
          render_to_string form
          form.assign params
        end
      end
    end
  end
end
