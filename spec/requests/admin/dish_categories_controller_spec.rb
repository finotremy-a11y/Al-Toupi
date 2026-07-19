require "rails_helper"

RSpec.describe "Admin::DishCategoriesController", type: :request do
  describe "authentication" do
    it "redirects guests to login" do
      get admin_dish_categories_path

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

    it "lists categories" do
      create(:dish_category, name: "Entrees")

      get admin_dish_categories_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Catégories de plats")
      expect(response.body).to include("Entrees")
    end

    it "creates category and redirects with flash" do
      expect do
        post admin_dish_categories_path, params: {
          dish_category: {
            name: "Desserts",
            category_type: "drinks",
            position: 5
          }
        }
      end.to change(DishCategory, :count).by(1)

      expect(response).to redirect_to(admin_dish_categories_path)
      follow_redirect!
      expect(response.body).to include("Catégorie créée avec succès.")
      expect(DishCategory.last.category_type).to eq("drinks")
    end

    it "renders new with unprocessable status when invalid" do
      post admin_dish_categories_path, params: { dish_category: { name: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Veuillez corriger les erreurs")
    end

    it "updates category with permitted params only" do
      category = create(:dish_category, name: "Avant")

      patch admin_dish_category_path(category), params: {
        dish_category: {
          name: "Apres",
          category_type: "drinks",
          position: 2,
          created_at: 10.years.ago
        }
      }

      expect(response).to redirect_to(admin_dish_categories_path)
      expect(category.reload.name).to eq("Apres")
      expect(category.category_type).to eq("drinks")
      expect(category.position).to eq(2)
      expect(category.created_at).to be > 1.year.ago
    end

    it "destroys category and redirects with flash" do
      category = create(:dish_category)

      expect do
        delete admin_dish_category_path(category)
      end.to change(DishCategory, :count).by(-1)

      expect(response).to redirect_to(admin_dish_categories_path)
      follow_redirect!
      expect(response.body).to include("Catégorie supprimée.")
    end
  end
end
