require "rails_helper"

RSpec.describe "Admin::SettingsController", type: :request do
  describe "authentication" do
    it "redirects guests to login" do
      get admin_settings_path

      expect(response).to redirect_to(login_path)
      follow_redirect!
      expect(response.body).to include("Veuillez vous connecter")
    end
  end

  describe "CRUD" do
    let!(:admin) { create(:admin_user) }

    before do
      sign_in_admin(admin)
    end

    it "lists settings" do
      create(:setting, key: "telephone", value: "01 02")

      get admin_settings_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Paramètres du site")
      expect(response.body).to include("telephone")
      expect(response.body).to include("Informations légales")
      expect(response.body).to include("Contenus du site")
      expect(response.body).to include("Raison sociale")
      expect(response.body).to include("legal_company_name")
      expect(response.body).to include("drink_intro")
      expect(response.body).to include("gallery_intro")
    end

    it "prefills key when opening new with key param" do
      get new_admin_setting_path, params: { key: "legal_company_name" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("value=\"legal_company_name\"")
      expect(response.body).to include("Clés utiles")
      expect(response.body).to include("drink_intro")
      expect(response.body).to include("gallery_intro")
      expect(response.body).to include("Saisissez la valeur affichée sur le site public")
    end

    it "creates setting and redirects with flash" do
      expect do
        post admin_settings_path, params: { setting: { key: "adresse", value: "Salles-Curan" } }
      end.to change(Setting, :count).by(1)

      expect(response).to redirect_to(admin_settings_path)
      follow_redirect!
      expect(response.body).to include("Paramètre créé.")
    end

    it "renders new on invalid create" do
      post admin_settings_path, params: { setting: { key: "", value: "x" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Veuillez corriger les erreurs")
    end

    it "updates setting and does not allow unpermitted attributes" do
      setting = create(:setting, key: "adresse", value: "Avant")

      patch admin_setting_path(setting), params: {
        setting: {
          value: "Apres",
          updated_at: 10.years.ago
        }
      }

      expect(response).to redirect_to(admin_settings_path)
      expect(setting.reload.value).to eq("Apres")
      expect(setting.updated_at).to be > 1.year.ago
    end

    it "destroys setting and redirects with flash" do
      setting = create(:setting)

      expect do
        delete admin_setting_path(setting)
      end.to change(Setting, :count).by(-1)

      expect(response).to redirect_to(admin_settings_path)
      follow_redirect!
      expect(response.body).to include("Paramètre supprimé.")
    end
  end
end
