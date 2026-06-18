require "rails_helper"

RSpec.describe "SessionsController", type: :request do
  describe "GET /login" do
    it "renders the login form" do
      get login_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Connexion")
    end

    it "redirects already logged in admins" do
      sign_in_admin

      get login_path

      expect(response).to redirect_to(admin_root_path)
    end
  end

  describe "POST /login" do
    let!(:admin) { create(:admin_user, email: "admin@altoupi.test") }

    it "authenticates and redirects to admin dashboard" do
      post login_path, params: { email: admin.email, password: "password123" }

      expect(response).to redirect_to(admin_root_path)
      follow_redirect!
      expect(response.body).to include("Bienvenue dans l&#39;administration.")
    end

    it "rejects invalid credentials" do
      post login_path, params: { email: admin.email, password: "wrong" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Email ou mot de passe incorrect.")
    end
  end

  describe "DELETE /logout" do
    it "logs out and redirects to login" do
      sign_in_admin

      delete logout_path

      expect(response).to redirect_to(login_path)
      follow_redirect!
      expect(response.body).to include("Vous avez été déconnecté.")
    end
  end
end
