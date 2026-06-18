class PagesController < ApplicationController
  def home
    @photos = Photo.ordered
  end

  def menu
    @categories = DishCategory.ordered.includes(dishes: { photo_attachment: :blob })
  end

  def gallery
    @photos = Photo.ordered.with_attached_image
  end

  def contact
  end
end
