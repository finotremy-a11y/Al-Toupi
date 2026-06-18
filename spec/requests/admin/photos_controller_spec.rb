require "rails_helper"

RSpec.describe "Admin::PhotosController", type: :request do
  describe "authentication" do
    it "redirects guests to login" do
      get admin_photos_path

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

    it "lists photos" do
      photo = create(:photo, title: "Vue terrasse")

      get admin_photos_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Vue terrasse")
      expect(response.body).to include("Galerie")
      expect(response.body).to include("Ajouter une photo")
      expect(response.body).to include(photo.title)
    end

    it "creates a photo with image upload and redirects with flash" do
      expect do
        post admin_photos_path, params: {
          photo: {
            title: "Nouvelle photo",
            position: 3,
            image: fixture_upload
          }
        }
      end.to change(Photo, :count).by(1)

      expect(response).to redirect_to(admin_photos_path)
      follow_redirect!
      expect(response.body).to include("Photo ajoutée avec succès.")
      expect(Photo.last.image).to be_attached
    end

    it "renders new with unprocessable status on invalid create" do
      post admin_photos_path, params: { photo: { title: "Sans image" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Veuillez corriger les erreurs")
    end

    it "updates a photo and redirects with flash" do
      photo = create(:photo, title: "Avant")

      patch admin_photo_path(photo), params: {
        photo: {
          title: "Apres",
          position: 10,
          created_at: 10.years.ago
        }
      }

      expect(response).to redirect_to(admin_photos_path)
      expect(photo.reload.title).to eq("Apres")
      expect(photo.position).to eq(10)
      expect(photo.created_at).to be > 1.year.ago
    end

    it "destroys a photo and redirects with flash" do
      photo = create(:photo)

      expect do
        delete admin_photo_path(photo)
      end.to change(Photo, :count).by(-1)

      expect(response).to redirect_to(admin_photos_path)
      follow_redirect!
      expect(response.body).to include("Photo supprimée.")
    end
  end
end
