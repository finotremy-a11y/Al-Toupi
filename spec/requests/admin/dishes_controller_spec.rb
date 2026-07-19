require "rails_helper"

RSpec.describe "Admin::DishesController", type: :request do
  let!(:category) { create(:dish_category, name: "Plats") }

  describe "authentication" do
    it "redirects guests to login" do
      get admin_dishes_path

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

    it "lists dishes" do
      create(:dish, dish_category: category, name: "Boeuf")

      get admin_dishes_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Visuels de la carte")
      expect(response.body).to include("Plats")
    end

    it "creates a dish with only category, photo and position" do
      expect do
        post admin_dishes_path, params: {
          dish: {
            dish_category_id: category.id,
            position: 1,
            photo: fixture_upload
          }
        }
      end.to change(Dish, :count).by(1)

      expect(response).to redirect_to(admin_dishes_path)
      follow_redirect!
      expect(response.body).to include("Plat ajouté avec succès.")
      expect(Dish.last.photo).to be_attached
      expect(Dish.last.price.to_f).to eq(0.01)
      expect(Dish.last.name).to start_with("Carte")
    end

    it "renders new on invalid create" do
      post admin_dishes_path, params: { dish: { dish_category_id: nil, photo: fixture_upload } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Veuillez corriger les erreurs")
    end

    it "renders new on create without photo" do
      post admin_dishes_path, params: { dish: { dish_category_id: category.id, position: 1 } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Veuillez corriger les erreurs")
    end

    it "updates a dish and keeps strong params enforced" do
      dish = create(:dish, dish_category: category, name: "Avant")

      patch admin_dish_path(dish), params: {
        dish: {
          position: 4,
          dish_category_id: category.id,
          created_at: 10.years.ago
        }
      }

      expect(response).to redirect_to(admin_dishes_path)
      expect(dish.reload.position).to eq(4)
      expect(dish.created_at).to be > 1.year.ago
    end

    it "destroys dish and redirects with flash" do
      dish = create(:dish, dish_category: category)

      expect do
        delete admin_dish_path(dish)
      end.to change(Dish, :count).by(-1)

      expect(response).to redirect_to(admin_dishes_path)
      follow_redirect!
      expect(response.body).to include("Plat supprimé.")
    end
  end
end
