class Admin::DashboardController < Admin::BaseController
  def index
    @photos_count         = Photo.count
    @dish_categories_count = DishCategory.count
    @dishes_count         = Dish.count
    @settings_count       = Setting.count
  end
end
