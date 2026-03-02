RSpec.describe Superform::Rails::Components::Datalist, type: :view do
  let(:object) { double("object", time_zone: "Pacific Time (US & Canada)") }
  let(:field) do
    Superform::Rails::Field.new(:time_zone, parent: nil, object: object)
  end

  it "renders an input linked to a datalist" do
    html = render(field.datalist("Eastern", "Central", "Pacific"))

    expect(html).to include('<input')
    expect(html).to include('list="time_zone_datalist"')
    expect(html).to include('<datalist id="time_zone_datalist">')
    expect(html).to include('<option value="Eastern">')
    expect(html).to include('<option value="Central">')
    expect(html).to include('<option value="Pacific">')
  end

  it "sets standard field attributes on the input" do
    html = render(field.datalist("Eastern"))

    expect(html).to include('id="time_zone"')
    expect(html).to include('name="time_zone"')
  end

  it "passes through HTML attributes to the input" do
    html = render(field.datalist("Eastern", class: "form-input", placeholder: "Start typing..."))

    expect(html).to include('class="form-input"')
    expect(html).to include('placeholder="Start typing..."')
  end

  it "accepts value/label pairs" do
    html = render(field.datalist(["est", "Eastern"], ["cst", "Central"]))

    expect(html).to include('value="est"')
    expect(html).to include("Eastern")
    expect(html).to include('value="cst"')
    expect(html).to include("Central")
  end

  it "accepts a hash of options" do
    html = render(field.datalist({ "est" => "Eastern", "cst" => "Central" }))

    expect(html).to include('value="est"')
    expect(html).to include("Eastern")
  end

  it "renders with a block for custom options" do
    component = field.datalist do |d|
      d.options("Eastern", "Central", "Pacific")
    end
    html = render(component)

    expect(html).to include('<input')
    expect(html).to include('list="time_zone_datalist"')
    expect(html).to include('<option value="Eastern">')
    expect(html).to include('<option value="Central">')
    expect(html).to include('<option value="Pacific">')
  end

  it "works as a one-liner for time zones" do
    zones = ["Eastern Time (US & Canada)", "Central Time (US & Canada)", "Pacific Time (US & Canada)"]
    html = render(field.datalist(*zones))

    expect(html).to include('value="Eastern Time (US & Canada)"')
    expect(html).to include('value="Pacific Time (US & Canada)"')
  end
end
