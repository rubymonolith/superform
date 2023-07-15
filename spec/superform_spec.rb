# frozen_string_literal: true

User = Data.define(:name, :nicknames, :addresses)
Address = Data.define(:street, :city, :state)

RSpec.describe Superform do
  let(:user) do
    User.new \
      name: "William",
      nicknames: ["Bill", "Billy", "Will"],
      addresses: [
        Address.new(street: "Birch Ave", city: "Williamsburg", state: "New Mexico"),
        { street: "Main St", city: "Salem", state: "Indiana"},
      ]
  end

  let(:params) do
    {
      name: "Brad",
      admin: true,
      nicknames: ["Brad", "Bradley"],
      addresses: [
        { street: "Main St", city: "Salem"},
        { street: "Wall St", city: "New York", state: "New York", admin: true }
      ],
      one: { two: { three: { four: 100 }}}
    }
  end

  let(:form) do
    Superform :user, object: user do |form|
      form.field(:name)
      form.field_collection(:nicknames) do |field|
        field.dom
      end
      form.namespace_collection(:addresses) do |address|
        address.field(:street)
        address.field(:city)
        address.field(:state)
      end
      form.namespace(:one).namespace(:two).namespace(:three).field(:four).value = 100
    end
  end

  it "serializes form" do
    expect(form.serialize).to eql({
      name: "William",
      nicknames: ["Bill", "Billy", "Will"],
      addresses: [
        {street: "Birch Ave", city: "Williamsburg", state: "New Mexico"},
        {street: "Main St", city: "Salem", state: "Indiana"},
      ],
      one: {two: {three: {four: 100}}}
    })
  end

  it "assigns params to form and discards garbage" do
    form.assign(params)
    expect(form.serialize).to eql({
      name: "Brad",
      nicknames: ["Brad", "Bradley"],
      addresses: [
        {street: "Main St", city: "Salem", state: nil},
        {street: "Wall St", city: "New York", state: "New York"}
      ],
      one: {two: {three: {four: 100}}}
    })
  end

  # it "has correct DOM names" do
  #   Superform.namespace :user, value: user do |form|
  #     form.field(:name).dom.tap do |dom|
  #       expect(dom.id).to eql("user_name")
  #       expect(dom.name).to eql("user[name]")
  #     end
  #     form.field(:nicknames).each do |field|
  #       field.dom.tap do |dom|
  #         expect(dom.id).to match /user_nicknames_\d+/
  #         expect(dom.name).to eql("user[nicknames][]")
  #       end
  #     end
  #     form.field(:addresses).each do |address|
  #       address.field(:street).dom.tap do |dom|
  #         expect(dom.id).to match /user_addresses_\d_street+/
  #         expect(dom.name).to eql("user[addresses][][street]")
  #       end
  #       address.field(:city)
  #       address.field(:state)
  #     end
  #     form.field(:one).field(:two).field(:three).field(:four, value: 100).dom
  #   end
  # end
end
