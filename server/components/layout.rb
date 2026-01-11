# frozen_string_literal: true

class Layout < Phlex::HTML
  def initialize(title: "Superform Examples")
    @title = title
  end

  def view_template(&)
    doctype
    html do
      head do
        title { @title }
        link rel: "stylesheet", href: "/pico.min.css"
      end
      body do
        main class: "container" do
          header do
            h1 { a(href: "/") { "Superform Examples" } }
          end
          yield
        end
      end
    end
  end
end
