require "rails_helper"

RSpec.describe "Admin::MenuCardsController", type: :request do
  describe "authentication" do
    it "redirects guests to login" do
      get admin_menu_card_path

      expect(response).to redirect_to(login_path)
    end

    it "redirects guest delete attempts to login" do
      delete admin_menu_card_path

      expect(response).to redirect_to(login_path)
    end
  end

  describe "show/update/destroy" do
    let!(:admin) { create(:admin_user) }

    before do
      sign_in_admin(admin)
    end

    it "renders upload page" do
      get admin_menu_card_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Carte du restaurant (fichier)")
      expect(response.body).to include("Formats autorisés")
    end

    it "creates and updates menu card with uploaded file" do
      patch admin_menu_card_path, params: {
        menu_card: {
          title: "Carte été",
          file: fixture_upload
        }
      }

      expect(response).to redirect_to(admin_menu_card_path)
      follow_redirect!
      expect(response.body).to include("Carte mise à jour avec succès.")

      menu_card = MenuCard.first
      expect(menu_card.title).to eq("Carte été")
      expect(menu_card.file).to be_attached
    end

    it "renders errors on invalid file" do
      temp = Tempfile.new([ "menu", ".txt" ])
      temp.write("text")
      temp.rewind
      bad_file = Rack::Test::UploadedFile.new(temp.path, "text/plain")

      patch admin_menu_card_path, params: {
        menu_card: {
          title: "Carte",
          file: bad_file
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Veuillez corriger les erreurs")
    ensure
      temp.close!
    end

    it "deletes uploaded menu card" do
      create(:menu_card)

      expect do
        delete admin_menu_card_path
      end.to change(MenuCard, :count).by(-1)

      expect(response).to redirect_to(admin_menu_card_path)
      follow_redirect!
      expect(response.body).to include("Carte supprimée. Retour à la carte manuelle activé.")
    end
  end
end
