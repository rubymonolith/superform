class BasicForm < ExampleForm
  def self.description = <<~HTML
    <p>Common input types: <code>text</code>, <code>email</code>, <code>password</code>, and <code>number</code>.</p>
  HTML

  def view_template
    render field(:name).label
    render field(:name).text(placeholder: "Your name")

    render field(:email).label
    render field(:email).email(placeholder: "you@example.com")

    render field(:password).label
    render field(:password).password

    render field(:age).label
    render field(:age).number(min: 0, max: 150)

    render submit("Save")
  end
end
