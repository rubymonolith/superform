RSpec.describe Superform::Rails::Form, type: :view do
  let(:model) { User.new(first_name: "John", last_name: "Doe", email: "john@example.com") }
  let(:form) { described_class.new(model, action: "/users") }

  describe "#initialize" do
    it "creates a form with a model" do
      expect(form.model).to eq(model)
    end

    it "creates a root namespace" do
      expect(form.instance_variable_get(:@namespace)).to be_a(Superform::Namespace)
    end
  end

  describe "#field" do
    it "delegates to the namespace" do
      field = form.field(:email)
      expect(field).to be_a(Superform::Rails::Form::Field)
      expect(field.key).to eq(:email)
    end
  end

  describe "#key" do
    it "returns the model's param key" do
      expect(form.key).to eq("user")
    end
  end

  describe "#render" do
    subject { render(form) }

    it { is_expected.to include('<form') }
    it { is_expected.to include('action="/users"') }
    it { is_expected.to include('method="post"') }
    it { is_expected.to include('name="authenticity_token"') }
    it { is_expected.to include('type="hidden"') }

    context "when model is persisted" do
      let(:model) { User.create!(first_name: "John", last_name: "Doe", email: "john@example.com") }
      let(:form) { described_class.new(model, action: "/users/#{model.id}") }

      it { is_expected.to include('name="_method"') }
      it "includes a hidden _method field for non-GET forms" do
        expect(subject).to match(/name="_method".*type="hidden"/m)
      end
    end

    context "when block is given" do
      subject do
        render(form) do |f|
          f.render f.field(:email).input(type: :email)
          f.render f.field(:first_name).input
          f.render f.field(:last_name).input
        end
      end

      it { is_expected.to include('name="user[email]"') }
      it { is_expected.to include('name="user[first_name]"') }
      it { is_expected.to include('name="user[last_name]"') }
    end

     context "Field kit" do
      subject do
        render(form) do |f|
          f.Field(:email).input(type: :email)
          f.Field(:first_name).input
          f.Field(:last_name).input
          f.namespace(:address).Field(:street).input
        end
      end

      it { is_expected.to include('name="user[email]"') }
      it { is_expected.to include('name="user[first_name]"') }
      it { is_expected.to include('name="user[last_name]"') }
      it { is_expected.to include('name="user[address][street]"') }
    end

    context "Kit in ERB template" do
      subject do
        render inline: <<~ERB, locals: { form: form }
          <div class="before">Before Kit</div>
          <%= render(form) do |f| %>
            <%= f.Field(:email).input(type: :email) %>
            <div class="between">Between Kit</div>
            <%= f.Field(:first_name).input
                f.Field(:last_name).input
             %>
          <% end %>
          <div class="after">After Kit</div>
        ERB
      end

      it "renders Kit fields in correct order with surrounding content" do
        expect(subject).to match(
          /Before Kit.*name="user\[email\]".*Between Kit.*id="user_first_name".*id="user_last_name".*After Kit/m
        )
      end
    end
  end
end
