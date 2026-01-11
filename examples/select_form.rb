class SelectForm < ExampleForm
  def self.description = <<~HTML
    <p><code>select</code> dropdowns with various option formats.</p>
  HTML

  COUNTRIES = [
    ["United States", "us"],
    ["Canada", "ca"],
    ["United Kingdom", "uk"],
    ["Germany", "de"],
    ["Japan", "jp"]
  ].freeze

  def view_template
    render field(:country).label
    render field(:country).select(options: COUNTRIES, include_blank: "Choose...")

    render field(:priority).label
    render field(:priority).select(options: %w[Low Medium High])

    render field(:quantity).label
    render field(:quantity).select(options: (1..10).to_a)

    render submit("Submit")
  end
end
