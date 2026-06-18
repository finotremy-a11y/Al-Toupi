require "rails_helper"

RSpec.describe "PagesController", type: :request do
  describe "GET /" do
    it "renders home with photos and settings text" do
      create(:setting, key: "texte_accueil", value: "Bienvenue test")
      create(:photo, title: "Facade")

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Bienvenue test")
      expect(response.body).to include("Facade")
    end
  end

  describe "GET /carte" do
    it "renders categories and dishes" do
      category = create(:dish_category, name: "Desserts")
      create(:dish, dish_category: category, name: "Tarte", description: "Maison", price: 6.5)

      get menu_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Desserts")
      expect(response.body).to include("Tarte")
    end
  end

  describe "GET /galerie" do
    it "renders photos" do
      create(:photo, title: "Salle")

      get gallery_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Galerie")
      expect(response.body).to include("Salle")
    end
  end

  describe "GET /contact" do
    it "renders contact settings" do
      create(:setting, key: "adresse", value: "1 rue de la Paix")
      create(:setting, key: "telephone", value: "010203")

      get contact_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("1 rue de la Paix")
      expect(response.body).to include("010203")
    end
  end
end
