class SpecialInputsForm < ExampleForm
  def self.name_text = "Special Inputs"

  def self.description = <<~HTML
    <p>HTML5 input types: <code>color</code>, <code>range</code>, <code>search</code>, and <code>file</code>.</p>
  HTML

  def view_template
    render field(:favorite_color).label
    render field(:favorite_color).color

    render field(:volume).label
    render field(:volume).range(min: 0, max: 100, step: 10)

    render field(:search_query).label
    render field(:search_query).search(placeholder: "Search...")

    render field(:avatar).label
    render field(:avatar).file(accept: "image/*")

    render submit("Apply")
  end
end
