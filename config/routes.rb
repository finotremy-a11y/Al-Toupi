Rails.application.routes.draw do
  # == Santé de l'app ==
  get "up" => "rails/health#show", as: :rails_health_check

  # == Partie publique ==
  root "pages#home"
  get "carte",   to: "pages#menu",    as: :menu
  get "galerie", to: "pages#gallery", as: :gallery
  get "contact", to: "pages#contact", as: :contact

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
