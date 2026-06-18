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
      expect(response.body).to include("aria-controls=\"mobile-menu\"")
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

    it "renders configured map iframe" do
      map_url = "https://www.google.com/maps?q=10+Rue+de+la+Confr%C3%A9rie%2C+12410+Salles-Curan&output=embed"
      create(:setting, key: "maps_embed_url", value: map_url)

      get contact_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(CGI.escapeHTML(map_url))
      expect(response.body).to include("Localisation Al Toupi")
    end
  end

  describe "GET /mentions-legales" do
    it "renders legal mentions page" do
      get legal_mentions_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mentions légales")
    end

    it "renders legal information from settings" do
      create(:setting, key: "legal_company_name", value: "SARL Test Toupi")
      create(:setting, key: "legal_director", value: "Camille Martin")
      create(:setting, key: "legal_host_name", value: "Hosteur Pro")

      get legal_mentions_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("SARL Test Toupi")
      expect(response.body).to include("Camille Martin")
      expect(response.body).to include("Hosteur Pro")
    end
  end

  describe "GET /politique-confidentialite" do
    it "renders privacy policy page" do
      get privacy_policy_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Politique de confidentialité")
    end
  end

  describe "GET /politique-cookies" do
    it "renders cookies policy page" do
      get cookies_policy_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Politique cookies")
    end
  end
end
