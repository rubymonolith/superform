RSpec.describe Superform::Rails::Form, type: :rails do
  let(:helpers) do
    double(
      "helpers",
      url_for: "/model",
      form_authenticity_token: "123"
    )
  end

  let(:model) do
    double(
      "model",
      model_name: double(param_key: "model"),
      persisted?: false
    )
  end

  before do
    allow_any_instance_of(described_class).to(
      receive(:helpers).and_return(helpers)
    )
  end

  it "sets the authenticity token by default" do
    render described_class.new(model, method: :get)

    expect(page).to have_css(
      "input[name='authenticity_token'][value='123']",
      visible: false
    )
  end

  it "removes authenticity token if set to false" do
    render described_class.new(model, authenticity_token: false, method: :get)

    expect(page).not_to have_field(name: "authenticity_token")
  end
end
