# frozen_string_literal: true

class Layout < Phlex::HTML
  def initialize(title: "Superform")
    @title = title
  end

  def view_template(&)
    doctype
    html do
      head do
        title { @title }
        link rel: "stylesheet", href: "/styles.css"
      end
      body do
        header do
          h1 { a(href: "/") { "Superform" } }
        end
        yield
      end
    end
  end
end
