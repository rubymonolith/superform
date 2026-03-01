RSpec.describe Superform::Rails::Components::Radio, type: :view do
  let(:object) { double('object', gender: "male") }
  let(:field) do
    Superform::Rails::Field.new(:gender, parent: nil, object: object)
  end

  it 'renders a checked radio when value matches' do
    html = render(field.radio("male"))
    expect(html).to include('type="radio"')
    expect(html).to include('id="gender_male"')
    expect(html).to include('name="gender"')
    expect(html).to include('value="male"')
    expect(html).to include('checked')
  end

  it 'renders an unchecked radio when value does not match' do
    html = render(field.radio("female"))
    expect(html).to include('id="gender_female"')
    expect(html).to include('value="female"')
    expect(html).not_to include('checked')
  end

  it 'accepts custom attributes' do
    html = render(field.radio("male", class: "radio-input"))
    expect(html).to include('class="radio-input"')
  end

  it 'renders a group with unique ids' do
    html = ""
    ["male", "female", "other"].each do |value|
      html += render(field.radio(value))
    end

    expect(html.scan(/type="radio"/).count).to eq(3)
    expect(html.scan(/name="gender"/).count).to eq(3)
    expect(html.scan(/checked/).count).to eq(1)
    expect(html).to include('id="gender_male"')
    expect(html).to include('id="gender_female"')
    expect(html).to include('id="gender_other"')
    expect(html).to match(/<input[^>]*value="male"[^>]*checked/)
  end
end
