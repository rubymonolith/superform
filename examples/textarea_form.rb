class TextareaForm < ExampleForm
  def self.description = <<~HTML
    <p>Text input and <code>textarea</code> for longer content.</p>
  HTML

  def view_template
    render field(:title).label
    render field(:title).text(placeholder: "Post title")

    render field(:body).label
    render field(:body).textarea(rows: 6, placeholder: "Write your content...")

    render submit("Publish")
  end
end
