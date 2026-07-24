require "rails_helper"

RSpec.describe "Public showcase", type: :system do
  it "displays settings, menu, gallery and contact content through navigation" do
    create(:setting, key: "texte_accueil", value: "Bienvenue dans notre maison")
    create(:setting, key: "menu_intro", value: "Cuisine locale et produits frais")
    create(:setting, key: "drink_intro", value: "Vins, bières et boissons fraîches")
    create(:setting, key: "gallery_intro", value: "Les instants du restaurant en images")
    create(:setting, key: "adresse", value: "Salles-Curan")
    create(:setting, key: "telephone", value: "01 02 03 04 05")
    create(:setting, key: "email", value: "contact@altoupi.test")
    create(:setting, key: "horaires", value: "Lun-Dim 12h-14h")

    category = create(:dish_category, name: "Desserts", position: 1)
    create(:dish, :with_photo, dish_category: category, name: "Tarte aux pommes", price: 7.5, position: 1)
    drink_category = create(:dish_category, :drinks, name: "Boissons", position: 2)
    create(:dish, :with_photo, dish_category: drink_category, position: 1)
    create(:photo, title: "Terrasse")
    create(:photo, title: "Salle")

    visit root_path
    expect(page).to have_content("Al Toupi")
    expect(page).to have_content("Bienvenue dans notre maison")
    expect(page).to have_link("Accueil")
    expect(page).to have_link("Notre Carte")
    expect(page).to have_link("Nos Boissons")
    expect(page).to have_link("Galerie")
    expect(page).to have_link("Contact")
    expect(page).to have_no_link("Découvrir la carte")
    expect(page).to have_no_link("Nous contacter")

    within("nav.al-nav") { click_link "Notre Carte" }
    expect(page).to have_current_path(menu_path)
    expect(page).to have_content("Desserts")
    expect(page).to have_css("img[alt='Carte Desserts']")
    expect(page).to have_content("Cuisine locale et produits frais")

    within("nav.al-nav") { click_link "Nos Boissons" }
    expect(page).to have_current_path(drinks_path)
    expect(page).to have_content("Nos Boissons")
    expect(page).to have_content("Boissons")
    expect(page).to have_content("Vins, bières et boissons fraîches")

    within("nav.al-nav") { click_link "Galerie" }
    expect(page).to have_current_path(gallery_path)
    expect(page).to have_content("Galerie")
    expect(page).to have_content("Terrasse")
    expect(page).to have_content("Les instants du restaurant en images")

    within("nav.al-nav") { click_link "Contact" }
    expect(page).to have_current_path(contact_path)
    expect(page).to have_content("Informations pratiques")
    expect(page).to have_content("Salles-Curan")
    expect(page).to have_content("01 02 03 04 05")
    expect(page).to have_content("contact@altoupi.test")

    within("nav.al-nav") { click_link "Accueil" }
    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Horaires d'ouverture")

    expect(page).to have_css("header")
    expect(page).to have_css("main")
    expect(page).to have_css("footer")
  end
end
