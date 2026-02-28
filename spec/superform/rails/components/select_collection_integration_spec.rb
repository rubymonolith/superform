RSpec.describe "Select in Collection Integration", type: :view do
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

  class Order < ActiveRecord::Base
    serialize :tag_ids, coder: JSON
  end

  let(:item_options) { [[1, "Coffee"], [2, "Tea"], [3, "Juice"]] }
  let(:tag_options) { [[1, "Ruby"], [2, "Rails"], [3, "Phlex"]] }

  def build_model(orders)
    User.new(first_name: "Test", email: "test@example.com").tap do |user|
      orders_list = orders
      user.define_singleton_method(:orders) { @orders ||= orders_list }
      user.define_singleton_method(:orders=) { |val| @orders = val }
    end
  end

  describe "single select in collection" do
    let(:model) { build_model([Order.new(item_id: 1), Order.new(item_id: 2)]) }
    let(:form) { Superform::Rails::Form.new(model, action: "/users") }

    it "renders selects with collection notation and pre-selects values" do
      html = render(form) do |f|
        f.collection(:orders).each do |order_namespace|
          f.render order_namespace.field(:item_id).select(*item_options)
        end
      end

      expect(html).to include('name="user[orders][0][item_id]"')
      expect(html).to include('name="user[orders][1][item_id]"')

      first_select = html.match(/<select[^>]*id="user_orders_0_item_id"[^>]*>.*?<\/select>/m)[0]
      expect(first_select).to include('<option selected value="1">Coffee</option>')

      second_select = html.match(/<select[^>]*id="user_orders_1_item_id"[^>]*>.*?<\/select>/m)[0]
      expect(second_select).to include('<option selected value="2">Tea</option>')
    end
  end

  describe "multiple select in collection" do
    let(:model) { build_model([Order.new(tag_ids: [1, 3]), Order.new(tag_ids: [2])]) }
    let(:form) { Superform::Rails::Form.new(model, action: "/users") }

    def render_multiple_select(form)
      render(form) do |f|
        f.collection(:orders).each do |order_namespace|
          f.render order_namespace.field(:tag_ids).select(*tag_options, multiple: true)
        end
      end
    end

    it "renders with correct field names and hidden inputs" do
      html = render_multiple_select(form)

      expect(html).to include('name="user[orders][0][tag_ids][]"')
      expect(html).to include('name="user[orders][1][tag_ids][]"')
      expect(html).to include('<input type="hidden" name="user[orders][0][tag_ids][]" value="">')
      expect(html).to include('<input type="hidden" name="user[orders][1][tag_ids][]" value="">')
    end

    it "pre-selects multiple options based on array values" do
      html = render_multiple_select(form)

      first_select = html.match(/<select[^>]*id="user_orders_0_tag_ids"[^>]*>.*?<\/select>/m)[0]
      expect(first_select).to include('<option selected value="1">Ruby</option>')
      expect(first_select).to include('<option selected value="3">Phlex</option>')
      expect(first_select).not_to include('<option selected value="2">Rails</option>')

      second_select = html.match(/<select[^>]*id="user_orders_1_tag_ids"[^>]*>.*?<\/select>/m)[0]
      expect(second_select).to include('<option selected value="2">Rails</option>')
    end
  end
end
