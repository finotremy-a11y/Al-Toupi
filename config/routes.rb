Rails.application.routes.draw do
  # == Santé de l'app ==
  get "up" => "rails/health#show", as: :rails_health_check

  # == Partie publique ==
  root "pages#home"
  get "carte",   to: "pages#menu",    as: :menu
  get "galerie", to: "pages#gallery", as: :gallery
  get "contact", to: "pages#contact", as: :contact
  get "mentions-legales", to: "pages#legal_mentions", as: :legal_mentions
  get "politique-confidentialite", to: "pages#privacy_policy", as: :privacy_policy
  get "politique-cookies", to: "pages#cookies_policy", as: :cookies_policy

  # == Authentification admin ==
  get    "login",  to: "sessions#new",     as: :login
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # == Espace admin ==
  namespace :admin do
    root "dashboard#index"
    resources :photos
    resources :dish_categories
    resources :dishes
    resources :settings
  end
end
