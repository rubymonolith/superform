class DateTimeForm < ExampleForm
  def self.description = <<~HTML
    <p><code>date</code>, <code>time</code>, and <code>datetime</code> input types.</p>
  HTML

  def view_template
    render field(:birth_date).label
    render field(:birth_date).date

    render field(:appointment_time).label
    render field(:appointment_time).time

    render field(:event_datetime).label
    render field(:event_datetime).datetime

    render submit("Schedule")
  end
end
