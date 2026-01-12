# frozen_string_literal: true

RSpec.describe "Checkbox in Collection Integration", type: :view do
  # Set up test database for collection models
  before(:all) do
    ActiveRecord::Schema.define do
      create_table :pizza_orders, force: true do |t|
        t.string :toppings
      end
    end unless ActiveRecord::Base.connection.table_exists?(:pizza_orders)
  end

  after(:all) do
    ActiveRecord::Schema.define do
      drop_table :pizza_orders if ActiveRecord::Base.connection.table_exists?(:pizza_orders)
    end
  end

  # Test model for collection (array of objects)
  class PizzaOrder < ActiveRecord::Base
    self.table_name = "pizza_orders"
    # Serialize toppings as array for multi-select checkboxes
    serialize :toppings, coder: JSON
  end

  describe "collection (array of objects with multi-select)" do
    let(:initial_orders) do
      [
        PizzaOrder.new(toppings: ["cheese", "pepperoni"]),
        PizzaOrder.new(toppings: ["mushrooms"])
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
    let(:topping_options) do
      [
        ["cheese", "Cheese"],
        ["pepperoni", "Pepperoni"],
        ["mushrooms", "Mushrooms"],
        ["olives", "Olives"]
      ]
    end

    it "renders checkboxes with collection notation" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:toppings).checkbox(*topping_options)
        end
      end

      # Collection uses model_name[collection_name][index][field_name][] notation
      # The final [] is for checkbox array submission
      expect(html).to include('name="user[orders][0][toppings][]"')
      expect(html).to include('name="user[orders][1][toppings][]"')
      expect(html.scan(/type="checkbox"/).count).to eq(8) # 4 checkboxes × 2 orders
    end

    it "pre-selects checkboxes based on collection values" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:toppings).checkbox(*topping_options)
        end
      end

      # Should have exactly 3 checked checkboxes total
      # First order: cheese, pepperoni (2 checked)
      # Second order: mushrooms (1 checked)
      expect(html.scan(/checked/).count).to eq(3)

      # "cheese" should be checked (first order)
      expect(html).to match(/<input[^>]*id="user_orders_0_toppings_cheese"[^>]*checked/)
      # "pepperoni" should be checked (first order)
      expect(html).to match(/<input[^>]*id="user_orders_0_toppings_pepperoni"[^>]*checked/)
      # "mushrooms" should be checked (second order)
      expect(html).to match(/<input[^>]*id="user_orders_1_toppings_mushrooms"[^>]*checked/)
    end

    it "does not check unselected options" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:toppings).checkbox(*topping_options)
        end
      end

      # "olives" should not be checked in either order
      expect(html).not_to match(/<input[^>]*id="user_orders_0_toppings_olives"[^>]*checked/)
      expect(html).not_to match(/<input[^>]*id="user_orders_1_toppings_olives"[^>]*checked/)

      # "mushrooms" should not be checked in first order
      expect(html).not_to match(/<input[^>]*id="user_orders_0_toppings_mushrooms"[^>]*checked/)
    end

    it "works with submitted params from collection" do
      # Simulate Rails params after form submission
      # Collection checkboxes submit as:
      # { "user" => { "orders" => [
      #   { "toppings" => ["olives", "mushrooms"] },
      #   { "toppings" => ["cheese", "pepperoni", "olives"] }
      # ] } }
      submitted_model = User.new(first_name: "Test", email: "test@example.com").tap do |user|
        user.define_singleton_method(:orders) do
          [
            PizzaOrder.new(toppings: ["olives", "mushrooms"]),
            PizzaOrder.new(toppings: ["cheese", "pepperoni", "olives"])
          ]
        end
      end
      submitted_form = Superform::Rails::Form.new(submitted_model, action: "/users")

      html = render(submitted_form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:toppings).checkbox(*topping_options)
        end
      end

      # Should have exactly 5 checked checkboxes
      # First order: olives, mushrooms (2 checked)
      # Second order: cheese, pepperoni, olives (3 checked)
      expect(html.scan(/checked/).count).to eq(5)

      # First order should have "olives" and "mushrooms" checked
      expect(html).to match(/<input[^>]*id="user_orders_0_toppings_olives"[^>]*checked/)
      expect(html).to match(/<input[^>]*id="user_orders_0_toppings_mushrooms"[^>]*checked/)

      # Second order should have "cheese", "pepperoni", "olives" checked
      expect(html).to match(/<input[^>]*id="user_orders_1_toppings_cheese"[^>]*checked/)
      expect(html).to match(/<input[^>]*id="user_orders_1_toppings_pepperoni"[^>]*checked/)
      expect(html).to match(/<input[^>]*id="user_orders_1_toppings_olives"[^>]*checked/)
    end

    it "wraps each checkbox in a label for clickability" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:toppings).checkbox(*topping_options)
        end
      end

      # Each checkbox should be wrapped in a label
      # 4 options × 2 orders = 8 labels
      expect(html.scan(/<label>/).count).to eq(8)
      expect(html.scan(/<\/label>/).count).to eq(8)
    end
  end

  describe "boolean checkboxes in collection" do
    before(:all) do
      ActiveRecord::Schema.define do
        create_table :tasks, force: true do |t|
          t.boolean :completed
        end
      end unless ActiveRecord::Base.connection.table_exists?(:tasks)
    end

    after(:all) do
      ActiveRecord::Schema.define do
        drop_table :tasks if ActiveRecord::Base.connection.table_exists?(:tasks)
      end
    end

    class Task < ActiveRecord::Base
    end

    let(:initial_tasks) do
      [
        Task.new(completed: true),
        Task.new(completed: false)
      ]
    end
    let(:model) do
      tasks_list = initial_tasks
      User.new(first_name: "Test", email: "test@example.com").tap do |user|
        user.define_singleton_method(:tasks) { @tasks ||= tasks_list }
        user.define_singleton_method(:tasks=) { |val| @tasks = val }
      end
    end
    let(:form) { Superform::Rails::Form.new(model, action: "/users") }

    it "renders boolean checkboxes with hidden fields in collection" do
      html = render(form) do |f|
        tasks_collection = f.collection(:tasks)
        tasks_collection.each do |task_namespace|
          f.render task_namespace.field(:completed).checkbox
        end
      end

      # Should have hidden fields for each checkbox (value="0")
      # Plus form authenticity_token and _method fields
      expect(html.scan(/type="hidden"[^>]*value="0"/).count).to eq(2)
      # Each task should have both hidden and checkbox inputs with same name
      expect(html.scan(/name="user\[tasks\]\[0\]\[completed\]"/).count).to eq(2) # hidden + checkbox
      expect(html.scan(/name="user\[tasks\]\[1\]\[completed\]"/).count).to eq(2) # hidden + checkbox
    end

    it "checks boolean checkboxes based on true/false values" do
      html = render(form) do |f|
        tasks_collection = f.collection(:tasks)
        tasks_collection.each do |task_namespace|
          f.render task_namespace.field(:completed).checkbox
        end
      end

      # First task is completed (true) - should be checked
      expect(html).to match(/<input[^>]*id="user_tasks_0_completed"[^>]*checked/)

      # Second task is not completed (false) - should not be checked
      expect(html).not_to match(/<input[^>]*id="user_tasks_1_completed"[^>]*checked/)
    end
  end
end
