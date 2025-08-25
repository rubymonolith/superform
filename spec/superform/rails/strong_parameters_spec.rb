# frozen_string_literal: true

module Users
  class Form < Superform::Rails::Form
    def view_template
      # Declaring fields is enough to register them on the form's namespace.
      field :first_name
      field :email
    end
  end
end

class UsersController < ApplicationController
  include Superform::Rails::StrongParameters

  def create
    @user = assign params.require(:user), to: Users::Form.new(User.new, action: "/users")
    head :ok
  end

  def update
    # Simulate fetching an existing persisted record
    @user = User.new(id: params[:id].to_i)
    assign params.require(:user), to: Users::Form.new(@user, action: "/users/#{@user.id}")
    head :ok
  end
end

RSpec.describe UsersController, type: :controller do
  render_views
  routes { Rails.application.routes }
  subject { controller.instance_variable_get(:@user) }

  describe "creating a user" do
    context "assigns only first_name and email, ignores last_name" do
      before do
        post :create, params: {
          user: {
            first_name: "Jane",
            last_name: "Roe",
            email: "jane@example.com"
          }
        }
      end

      it { is_expected.to have_attributes(first_name: "Jane", email: "jane@example.com", last_name: nil) }
    end



    context "ignores last_name when submitted explicitly" do
      before do
        post :create, params: {
          user: {
            first_name: "Zoe",
            last_name: "ShouldNotSet",
            email: "zoe@example.com"
          }
        }
      end

      it { is_expected.to have_attributes(first_name: "Zoe", email: "zoe@example.com", last_name: nil) }
    end
  end

  describe "updating a user" do
    context "does not allow mass-assigning protected attributes like id" do
      before do
        patch :update, params: {
          id: "1",
          user: {
            email: "updated@example.com",
            id: 999 # attempt to overwrite id via params
          }
        }
      end

      it { is_expected.to have_attributes(id: 1, email: "updated@example.com") }
    end


  end
end
