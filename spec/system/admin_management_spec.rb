require "rails_helper"

RSpec.describe "Admin management", type: :system do
  let!(:admin_user) { create(:admin_user, email: "admin@altoupi.test") }

  it "handles admin login, CRUD resources, uploads and logout" do
    visit login_path
    fill_in "Email", with: admin_user.email
    fill_in "Mot de passe", with: "password123"
    click_button "Se connecter"

    expect(page).to have_content("Tableau de bord")

    click_link "Galerie"
    click_link "Ajouter une photo"
    fill_in "Titre", with: "Soiree jazz"
    fill_in "Position", with: "1"
    attach_file "Image", Rails.root.join("public/icon.png")
    click_button "Ajouter"

    expect(page).to have_content("Photo ajoutée avec succès.")
    expect(page).to have_content("Soiree jazz")

    first(:link, "✏️ Modifier").click
    fill_in "Titre", with: "Soiree mise a jour"
    click_button "Enregistrer"
    expect(page).to have_content("Photo mise à jour.")

    first(:button, "🗑️ Supprimer").click
    expect(page).to have_content("Photo supprimée.")

    click_link "Catégories"
    click_link "Ajouter une catégorie"
    fill_in "Nom", with: "Plats"
    select "Carte", from: "Type"
    fill_in "Position", with: "1"
    click_button "Créer"
    expect(page).to have_content("Catégorie créée avec succès.")

    first(:link, "✏️ Modifier").click
    fill_in "Nom", with: "Plats signatures"
    click_button "Enregistrer"
    expect(page).to have_content("Catégorie mise à jour.")

    click_link "Plats"
    click_link "Ajouter un plat"
    select "Plats signatures", from: "Catégorie"
    fill_in "Position", with: "1"
    attach_file "Photo du plat", Rails.root.join("public/icon.png")
    click_button "Ajouter"

    expect(page).to have_content("Plat ajouté avec succès.")
    expect(page).to have_content("Plats signatures")

    first(:link, "✏️ Modifier").click
    fill_in "Position", with: "2"
    click_button "Enregistrer"
    expect(page).to have_content("Plat mis à jour.")

    click_link "Paramètres"
    click_link "Ajouter un paramètre"
    fill_in "Clé (identifiant technique)", with: "texte_accueil"
    fill_in "Valeur", with: "Bienvenue chez Al Toupi"
    click_button "Créer"
    expect(page).to have_content("Paramètre créé.")

    first(:link, "✏️ Modifier").click
    fill_in "Valeur", with: "Bienvenue mise a jour"
    click_button "Enregistrer"
    expect(page).to have_content("Paramètre mis à jour.")

    click_button "🚪 Déconnexion"
    expect(page).to have_content("Vous avez été déconnecté.")
    expect(page).to have_current_path(login_path)
  end
end
