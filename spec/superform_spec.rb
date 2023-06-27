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
      nicknames: ["Billy", "Swanson"],
      addresses: [
        { street: "Main St", city: "Salem", state: "Indiana"},
        { street: "Wall St", city: "New York", state: "New York", admin: true }
      ],
      one: { two: { three: { four: 100 }}}
    }
  end

  let(:form) do
    Superform::Field.root :user, builder: Superform::ObjectBuilder.new(user) do |form|
      form.field(:name)
      form.field(:nicknames).each do |field|
        pp field.dom
      end
      form.field(:addresses).each do |address|
        address.field(:street)
        address.field(:city)
        address.field(:state)
      end
      form.field(:one).field(:two).field(:three).field(:four, value: 100).dom
    end
  end

  it "permits params only in form" do
    expect(Superform::ParametersMapper.new(params).permit(form)).to eql({
      name: "Brad",
      nicknames: ["Billy", "Swanson"],
      addresses: [
        {street: "Main St", city: "Salem", state: "Indiana"},
        {street: "Wall St", city: "New York", state: "New York"}
      ],
      one: {two: {three: {four: 100}}}
    })
  end
end
