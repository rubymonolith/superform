# frozen_string_literal: true

RSpec.describe "Radio in Collection Integration", type: :view do
  # Set up test database for collection models
  before(:all) do
    ActiveRecord::Schema.define do
      create_table :orders, force: true do |t|
        t.string :sushi
      end
    end unless ActiveRecord::Base.connection.table_exists?(:orders)
  end

  after(:all) do
    ActiveRecord::Schema.define do
      drop_table :orders if ActiveRecord::Base.connection.table_exists?(:orders)
    end
  end

  # Test model for collection (array of objects)
  class Order < ActiveRecord::Base
  end

  # Note: Field collections (arrays of primitives) don't make sense for radio buttons
  # since radios are for single-select, not multiple array elements.
  # For multi-select from primitives, use checkboxes instead.

  describe "collection (array of objects)" do
    let(:initial_orders) do
      [
        Order.new(sushi: "shirako"),
        Order.new(sushi: "ankimo")
      ]
    end
    let(:model) do
      # Simulates a model with has_many association
      # Using User with a mock orders association
      orders_list = initial_orders # capture for closure
      User.new(first_name: "Test", email: "test@example.com").tap do |user|
        user.define_singleton_method(:orders) { @orders ||= orders_list }
        user.define_singleton_method(:orders=) { |val| @orders = val }
      end
    end
    let(:form) { Superform::Rails::Form.new(model, action: "/users") }

    it "renders radio buttons with collection notation" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:sushi).radio(
            ["shirako", "Shirako"],
            ["ankimo", "Ankimo"],
            ["tsubugai", "Tsubugai"]
          )
        end
      end

      # Collection uses model_name[collection_name][index][field_name] notation
      # Rails will parse { "0" => {}, "1" => {} } into an array
      expect(html).to include('name="user[orders][0][sushi]"')
      expect(html).to include('name="user[orders][1][sushi]"')
      expect(html.scan(/type="radio"/).count).to eq(6) # 3 radios × 2 orders
    end

    it "pre-selects radio buttons based on collection values" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:sushi).radio(
            ["shirako", "Shirako"],
            ["ankimo", "Ankimo"],
            ["tsubugai", "Tsubugai"]
          )
        end
      end

      # Should have exactly 2 checked radios (one per order)
      expect(html.scan(/checked/).count).to eq(2)
      # "shirako" should be checked (first order)
      expect(html).to match(/<input[^>]*id="user_orders_0_sushi_shirako"[^>]*checked/)
      # "ankimo" should be checked (second order)
      expect(html).to match(/<input[^>]*id="user_orders_1_sushi_ankimo"[^>]*checked/)
    end

    it "works with submitted params from collection" do
      # Simulate Rails params after form submission
      # Collection radios submit as: { "user" => { "orders" => [{ "sushi" => "tsubugai" }, { "sushi" => "shirako" }] } }
      submitted_model = User.new(first_name: "Test", email: "test@example.com").tap do |user|
        user.define_singleton_method(:orders) do
          [
            Order.new(sushi: "tsubugai"),
            Order.new(sushi: "shirako")
          ]
        end
      end
      submitted_form = Superform::Rails::Form.new(submitted_model, action: "/users")

      html = render(submitted_form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:sushi).radio(
            ["shirako", "Shirako"],
            ["ankimo", "Ankimo"],
            ["tsubugai", "Tsubugai"]
          )
        end
      end

      # Should have exactly 2 checked radios
      expect(html.scan(/checked/).count).to eq(2)
      # First order should now have "tsubugai" checked
      expect(html).to match(/<input[^>]*id="user_orders_0_sushi_tsubugai"[^>]*checked/)
      # Second order should now have "shirako" checked
      expect(html).to match(/<input[^>]*id="user_orders_1_sushi_shirako"[^>]*checked/)
    end
  end
end
