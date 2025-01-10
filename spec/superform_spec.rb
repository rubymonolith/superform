# frozen_string_literal: true
require "ostruct"

RSpec.describe Superform do
  let(:user) do
    OpenStruct.new \
      name: OpenStruct.new(first: "William", last: "Bills"),
      email: "william@example.com",
      nicknames: ["Bill", "Billy", "Will"],
      addresses: [
        OpenStruct.new(street: "Birch Ave", city: "Williamsburg", state: "New Mexico"),
        OpenStruct.new(street: "Main St", city: "Salem", state: "Indiana"),
      ]
  end

  let(:params) do
    {
      name: { first: "Brad", last: "Gessler", admin: true },
      admin: true,
      nicknames: ["Brad", "Bradley"],
      addresses: [
        { street: "Main St", city: "Salem"},
        { street: "Wall St", city: "New York", state: "New York", admin: true },
      ],
      one: { two: { three: { four: 100 }}}
    }
  end

  let(:form) do
    Superform :user, object: user do |form|
      form.namespace(:name) do |name|
        name.field(:first)
        name.field(:last)
      end
      form.field(:nicknames).collection do |field|
        field.value
      end
      form.collection(:addresses) do |address|
        address.field(:street)
        address.field(:city)
        address.field(:state)
      end
      form.namespace(:one).namespace(:two).namespace(:three).field(:four).value = 100
    end
  end

  it "serializes form" do
    expect(form.serialize).to eql({
      name: { first: "William", last: "Bills" },
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
      name: { first: "Brad", last: "Gessler" },
      nicknames: ["Brad", "Bradley"],
      addresses: [
        {street: "Main St", city: "Salem", state: nil},
        {street: "Wall St", city: "New York", state: "New York"}
      ],
      one: {two: {three: {four: 100}}}
    })
  end

  it "has correct DOM names" do
    Superform :user, object: user do |form|
      form.namespace(:name) do |name|
        name.field(:first).dom.tap do |dom|
          expect(dom.id).to eql("user_name_first")
          expect(dom.name).to eql("user[name][first]")
        end
      end
      form.field(:nicknames).collection do |field|
        field.dom.tap do |dom|
          expect(dom.id).to match /user_nicknames_\d+/
          expect(dom.name).to eql("user[nicknames][]")
        end
      end
      form.collection(:addresses) do |address|
        address.field(:street).dom.tap do |dom|
          expect(dom.id).to match /user_addresses_\d_street+/
          expect(dom.name).to eql("user[addresses][][street]")
        end
        address.field(:city)
        address.field(:state)
      end
      form.namespace(:one).namespace(:two).namespace(:three).field(:four).dom.tap do |dom|
        expect(dom.id).to eql("user_one_two_three_four")
        expect(dom.name).to eql("user[one][two][three][four]")
      end
    end
  end

  context "input behavior" do
    let(:form_with_email_field) do
      Superform :user, object: user, field_class: Superform::Rails::Form::Field do |f|
        f.field(:admin)
      end
    end

    it "returns an InputComponent when calling input on a standalone field" do
      expect(form_with_email_field.field(:email).input).to be_a(Superform::Rails::Components::InputComponent)
      expect(form_with_email_field.field(:email).input.dom.name).to eql("user[email]")
    end

    it "returns an InputComponent when calling input on a field within a namespace" do
      form_with_ns = Superform :user, object: user, field_class: Superform::Rails::Form::Field do |f|
        f.namespace(:settings) do |settings|
          settings.field(:locale)
        end
      end

      expect(form_with_ns.namespace(:settings).field(:locale).input).to be_a(Superform::Rails::Components::InputComponent)
      expect(form_with_ns.namespace(:settings).field(:locale).input.dom.name).to eql("user[settings][locale]")
    end
  end
end
