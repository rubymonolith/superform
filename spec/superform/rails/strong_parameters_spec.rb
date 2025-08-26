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
      let!(:existing_user) { User.create!(first_name: "Original", email: "original@example.com") }
      
      before do
        patch :update, params: {
          id: existing_user.id,
          user: {
            first_name: "Updated",
            email: "updated@example.com",
            id: 999 # attempt to overwrite id via params
          }
        }
      end

      it { is_expected.to have_attributes(first_name: "Updated", email: "updated@example.com") }
      it "keeps id sourced from the route, not params payload" do
        expect(subject.id).to eq(existing_user.id)
      end
    end
  end

  describe "create (save)" do
    context "valid params" do
      before do
        post :create, params: {
          user: {
            first_name: "Perm",
            email: "perm@example.com"
          }
        }
      end

      it "returns ok and assigns permitted attributes" do
        expect(response).to have_http_status(:ok)
        expect(subject).to have_attributes(first_name: "Perm", email: "perm@example.com")
      end
    end

    context "invalid params" do
      before do
        post :create, params: {
          user: {
            email: "perm@example.com"
          }
        }
      end

      it "returns unprocessable_entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "update (save!)" do
    context "invalid params" do
      let!(:existing_user) { User.create!(first_name: "Test", email: "test@example.com") }
      
      it "raises" do
        expect {
          patch :update, params: {
            id: existing_user.id,
            user: {
              email: "perm@example.com"
            }
          }
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "valid params" do
      let!(:existing_user) { User.create!(first_name: "Original", email: "original@example.com") }
      
      before do
        patch :update, params: {
          id: existing_user.id,
          user: {
            first_name: "Perm",
            email: "perm@example.com"
          }
        }
      end

      it "returns ok and assigns permitted attributes" do
        expect(response).to have_http_status(:ok)
        expect(subject).to have_attributes(first_name: "Perm", email: "perm@example.com")
      end
    end
  end
end
