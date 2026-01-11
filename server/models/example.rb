# frozen_string_literal: true

class Example
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :password, :string
  attribute :age, :integer
  attribute :title, :string
  attribute :body, :string
  attribute :country, :string
  attribute :priority, :string
  attribute :quantity, :integer
  attribute :terms_accepted, :boolean
  attribute :subscribe, :boolean
  attribute :featured, :boolean
  attribute :birth_date, :date
  attribute :appointment_time, :time
  attribute :event_datetime, :datetime
  attribute :favorite_color, :string
  attribute :volume, :integer
  attribute :search_query, :string
  attribute :avatar, :string
  attribute :address, :string

  def self.model_name
    ActiveModel::Name.new(self, nil, "Example")
  end
end
