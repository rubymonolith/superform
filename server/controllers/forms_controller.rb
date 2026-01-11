# frozen_string_literal: true

class FormsController < ActionController::Base
  before_action { Rails.autoloaders.main.reload }
  class IndexPage < Phlex::HTML
    def view_template
      render Layout.new do
        form_classes.each_with_index do |form_class, index|
          render FormCard.new(form_class: form_class, index: index)
        end
      end
    end
  end

  class ShowPage < Phlex::HTML
    def initialize(form_class:)
      @form_class = form_class
      @form = form_class.new(Example.new, action: "#")
    end

    def view_template
      render Layout.new(title: "#{@form_class.name_text} - Superform Examples") do
        p { a(href: "/") { "Back to all forms" } }

        h2 { @form_class.name_text }
        p { @form_class.description.html_safe }
        render @form

        hr

        h3 { "Source Code" }
        pre do
          code { source_code }
        end
      end
    end

    private

    def source_code
      file = File.join(EXAMPLES_DIR, "#{underscore(@form_class.name)}.rb")
      File.exist?(file) ? File.read(file) : "# Source not found"
    end

    def underscore(name)
      name.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
    end
  end

  def index
    render IndexPage.new, layout: false
  end

  def show
    index = params[:id].to_i
    form_class = form_classes[index]
    render ShowPage.new(form_class: form_class), layout: false
  end
end
