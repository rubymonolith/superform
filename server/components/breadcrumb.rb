# frozen_string_literal: true

class Breadcrumb < Phlex::HTML
  def view_template(&)
    nav(class: "breadcrumb") { yield self }
  end

  def crumb(&)
    span(class: "crumb") { yield }
  end
end
