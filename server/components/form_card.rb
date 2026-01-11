# frozen_string_literal: true

class FormCard < Phlex::HTML
  def initialize(form_class:, index:)
    @form_class = form_class
    @index = index
  end

  def view_template
    h2 { a(href: "/forms/#{@index}") { @form_class.name_text } }
    p { @form_class.description.html_safe }
  end
end
