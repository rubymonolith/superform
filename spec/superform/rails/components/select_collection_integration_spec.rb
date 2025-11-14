# frozen_string_literal: true

RSpec.describe "Select in Collection Integration", type: :view do
  # Set up test database for collection models
  before(:all) do
    ActiveRecord::Schema.define do
      create_table :orders, force: true do |t|
        t.integer :item_id
        t.string :tag_ids
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
    # Serialize tag_ids as JSON array for multiple select testing
    serialize :tag_ids, coder: JSON
  end

  describe "single select in collection" do
    let(:initial_orders) do
      [
        Order.new(item_id: 1),
        Order.new(item_id: 2)
      ]
    end
    let(:model) do
      User.new(first_name: "Test", email: "test@example.com").tap do |user|
        orders_list = initial_orders
        user.define_singleton_method(:orders) { @orders ||= orders_list }
        user.define_singleton_method(:orders=) { |val| @orders = val }
      end
    end
    let(:form) { Superform::Rails::Form.new(model, action: "/users") }
    let(:item_options) { [[1, "Coffee"], [2, "Tea"], [3, "Juice"]] }

    it "renders select with collection notation" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:item_id).select(options: item_options)
        end
      end

      # Collection uses model_name[collection_name][index][field_name] notation
      expect(html).to include('name="user[orders][0][item_id]"')
      expect(html).to include('name="user[orders][1][item_id]"')
    end

    it "pre-selects options based on collection values" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:item_id).select(options: item_options)
        end
      end

      # First order should have item_id=1 (Coffee) selected
      first_select = html.match(/<select[^>]*id="user_orders_0_item_id"[^>]*>.*?<\/select>/m)[0]
      expect(first_select).to include('<option selected value="1">Coffee</option>')

      # Second order should have item_id=2 (Tea) selected
      second_select = html.match(/<select[^>]*id="user_orders_1_item_id"[^>]*>.*?<\/select>/m)[0]
      expect(second_select).to include('<option selected value="2">Tea</option>')
    end

    it "works with submitted params from collection" do
      # Simulate Rails params after form submission
      submitted_model = User.new(first_name: "Test", email: "test@example.com").tap do |user|
        user.define_singleton_method(:orders) do
          [
            Order.new(item_id: 3),  # Changed to Juice
            Order.new(item_id: 1)   # Changed to Coffee
          ]
        end
      end
      submitted_form = Superform::Rails::Form.new(submitted_model, action: "/users")

      html = render(submitted_form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:item_id).select(options: item_options)
        end
      end

      # First order should now have item_id=3 (Juice) selected
      first_select = html.match(/<select[^>]*id="user_orders_0_item_id"[^>]*>.*?<\/select>/m)[0]
      expect(first_select).to include('<option selected value="3">Juice</option>')

      # Second order should now have item_id=1 (Coffee) selected
      second_select = html.match(/<select[^>]*id="user_orders_1_item_id"[^>]*>.*?<\/select>/m)[0]
      expect(second_select).to include('<option selected value="1">Coffee</option>')
    end
  end

  describe "multiple select in collection" do
    let(:initial_orders) do
      [
        Order.new(tag_ids: [1, 3]),
        Order.new(tag_ids: [2])
      ]
    end
    let(:model) do
      User.new(first_name: "Test", email: "test@example.com").tap do |user|
        orders_list = initial_orders
        user.define_singleton_method(:orders) { @orders ||= orders_list }
        user.define_singleton_method(:orders=) { |val| @orders = val }
      end
    end
    let(:form) { Superform::Rails::Form.new(model, action: "/users") }
    let(:tag_options) { [[1, "Ruby"], [2, "Rails"], [3, "Phlex"]] }

    it "renders multiple select with correct field names" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:tag_ids).select(
            options: tag_options,
            multiple: true
          )
        end
      end

      # Multiple select in collection should use [index][field_name][] notation
      expect(html).to include('name="user[orders][0][tag_ids][]"')
      expect(html).to include('name="user[orders][1][tag_ids][]"')
      # Should include multiple attribute
      expect(html.scan(/multiple/).count).to eq(2)
    end

    it "renders hidden inputs for empty submissions" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:tag_ids).select(
            options: tag_options,
            multiple: true
          )
        end
      end

      # Should have hidden inputs before each select
      expect(html).to include('<input type="hidden" name="user[orders][0][tag_ids][]" value="">')
      expect(html).to include('<input type="hidden" name="user[orders][1][tag_ids][]" value="">')
    end

    it "pre-selects multiple options based on array values" do
      html = render(form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:tag_ids).select(
            options: tag_options,
            multiple: true
          )
        end
      end

      # First order should have Ruby (1) and Phlex (3) selected
      # Extract just the first select element for testing
      first_select = html.match(/<select[^>]*id="user_orders_0_tag_ids"[^>]*>.*?<\/select>/m)[0]
      expect(first_select).to include('<option selected value="1">Ruby</option>')
      expect(first_select).to include('<option selected value="3">Phlex</option>')
      # First order should NOT have Rails (2) selected
      expect(first_select).to include('<option value="2">Rails</option>')
      expect(first_select).not_to include('<option selected value="2">Rails</option>')

      # Second order should have Rails (2) selected
      second_select = html.match(/<select[^>]*id="user_orders_1_tag_ids"[^>]*>.*?<\/select>/m)[0]
      expect(second_select).to include('<option selected value="2">Rails</option>')
    end

    it "works with submitted params for multiple select" do
      # Simulate Rails params after form submission
      submitted_model = User.new(first_name: "Test", email: "test@example.com").tap do |user|
        user.define_singleton_method(:orders) do
          [
            Order.new(tag_ids: [2, 3]),  # Changed to Rails + Phlex
            Order.new(tag_ids: [1, 2, 3]) # Changed to all three
          ]
        end
      end
      submitted_form = Superform::Rails::Form.new(submitted_model, action: "/users")

      html = render(submitted_form) do |f|
        orders_collection = f.collection(:orders)
        orders_collection.each do |order_namespace|
          f.render order_namespace.field(:tag_ids).select(
            options: tag_options,
            multiple: true
          )
        end
      end

      # First order should now have Rails (2) and Phlex (3) selected
      first_select = html.match(/<select[^>]*id="user_orders_0_tag_ids"[^>]*>.*?<\/select>/m)[0]
      expect(first_select).to include('<option selected value="2">Rails</option>')
      expect(first_select).to include('<option selected value="3">Phlex</option>')

      # Second order should have all three selected
      second_select = html.match(/<select[^>]*id="user_orders_1_tag_ids"[^>]*>.*?<\/select>/m)[0]
      expect(second_select).to include('<option selected value="1">Ruby</option>')
      expect(second_select).to include('<option selected value="2">Rails</option>')
      expect(second_select).to include('<option selected value="3">Phlex</option>')
    end
  end
end
