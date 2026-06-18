# == Seeds Al Toupi ==
# Charge les données initiales de développement/démo
# Pour relancer : rails db:seed

puts "Nettoyage des données existantes..."
Dish.destroy_all
DishCategory.destroy_all
Setting.destroy_all
AdminUser.destroy_all

# ---- Admin ----
puts "Création de l'admin..."
AdminUser.create!(
  email: "admin@altoupi.fr",
  password: "admin1234",
  password_confirmation: "admin1234"
)

# ---- Settings ----
puts "Création des paramètres..."
[
  { key: "texte_accueil", value: "Bienvenue au restaurant Al Toupi, une cuisine généreuse et authentique au cœur de l'Aveyron. Venez découvrir nos spécialités locales dans un cadre chaleureux, face au lac de Pareloup." },
  { key: "about_text", value: "Al Toupi est un restaurant traditionnel situé à Salles-Curan, en Aveyron. Depuis sa création, nous vous accueillons pour une expérience culinaire authentique mettant à l'honneur les produits du terroir et les spécialités de la région." },
  { key: "adresse", value: "10 Rue de la Confrérie\n12410 Salles-Curan" },
  { key: "telephone", value: "05 65 46 XX XX" },
  { key: "email", value: "contact@altoupi.fr" },
  { key: "horaires", value: "Lundi – Vendredi : 12h–14h / 19h–22h\nSamedi : 12h–22h\nDimanche : Fermé" },
  { key: "menu_intro", value: "Nos spécialités ? Les viandes succulentes de la région, les fromages d'Aveyron, et une cuisine généreuse qui célèbre les traditions. Chaque plat est préparé avec les meilleurs produits du terroir." },
  { key: "facebook", value: "" },
  { key: "instagram", value: "" },
  { key: "maps_embed_url", value: "https://www.google.com/maps?q=10+Rue+de+la+Confr%C3%A9rie%2C+12410+Salles-Curan&output=embed" },
  { key: "legal_company_name", value: "Al Toupi" },
  { key: "legal_director", value: "Direction Al Toupi" },
  { key: "legal_host_name", value: "Hébergeur à renseigner" },
  { key: "legal_host_address", value: "Adresse hébergeur" },
  { key: "legal_host_phone", value: "Téléphone hébergeur" }
].each { |s| Setting.create!(s) }

# ---- Catégories & plats ----
puts "Création des catégories et plats..."

entrees = DishCategory.create!(name: "Entrées", position: 1)
plats   = DishCategory.create!(name: "Plats",   position: 2)
desserts = DishCategory.create!(name: "Desserts", position: 3)

[
  { name: "Salade aveyronaise",   description: "Lardons, roquefort, noix, vinaigrette au miel",  price: 9.50,  position: 1, dish_category: entrees },
  { name: "Soupe paysanne",       description: "Légumes du terroir mijotés",                     price: 7.00,  position: 2, dish_category: entrees },
  { name: "Aligot maison",        description: "Pommes de terre, tome fraîche, ail",              price: 14.00, position: 1, dish_category: plats },
  { name: "Entrecôte aubrac",     description: "Race Aubrac, frites maison, sauce roquefort",     price: 22.50, position: 2, dish_category: plats },
  { name: "Truite à la crème",    description: "Filet de truite, crème, champignons des bois",   price: 18.00, position: 3, dish_category: plats },
  { name: "Fondant au chocolat",  description: "Coulant chaud, crème anglaise maison",            price: 7.00,  position: 1, dish_category: desserts },
  { name: "Crème brûlée",         description: "Vanille bourbon, caramel croustillant",           price: 6.50,  position: 2, dish_category: desserts },
  { name: "Assiette de fromages", description: "Sélection d'Aveyron : Roquefort, Laguiole, Bleu", price: 8.00, position: 3, dish_category: desserts }
].each { |d| Dish.create!(d) }

puts "Seeds terminées !"
puts "  Admin : admin@altoupi.fr / admin1234"
