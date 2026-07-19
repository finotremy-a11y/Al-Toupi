class PagesController < ApplicationController
  def home
    @photos = Photo.ordered
  end

  def menu
    @menu_card = MenuCard.first
    @categories = DishCategory.menu.ordered.includes(dishes: { photo_attachment: :blob })
  end

  def drinks
    @drink_categories = DishCategory.drinks.ordered.includes(dishes: { photo_attachment: :blob })
  end

  def gallery
    @photos = Photo.ordered.with_attached_image
  end

  def contact
  end

  def legal_mentions
  end

  def privacy_policy
  end

  def cookies_policy
  end
end
