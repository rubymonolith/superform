class CheckboxForm < ExampleForm
  def self.description = <<~HTML
    <p><code>checkbox</code> inputs with labels inside a fieldset.</p>
  HTML

  def view_template
    fieldset do
      legend { "Preferences" }

      label do
        render field(:terms_accepted).checkbox
        plain " I accept the terms"
      end

      label do
        render field(:subscribe).checkbox
        plain " Subscribe to newsletter"
      end

      label do
        render field(:featured).checkbox
        plain " Feature this item"
      end
    end

    render submit("Continue")
  end
end
