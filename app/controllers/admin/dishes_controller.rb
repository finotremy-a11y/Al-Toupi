class Admin::DishesController < Admin::BaseController
  before_action :set_dish, only: %i[edit update destroy]

  def index
    @dishes = Dish.includes(:dish_category).ordered
  end

  def new
    @dish = Dish.new
    @dish_categories = DishCategory.ordered
  end

  def create
    @dish = Dish.new(dish_params)
    apply_photo_only_defaults(@dish)

    unless @dish.photo.attached?
      @dish.errors.add(:photo, "doit être ajoutée")
      @dish_categories = DishCategory.ordered
      return render :new, status: :unprocessable_entity
    end

    if @dish.save
      redirect_to admin_dishes_path, notice: "Plat ajouté avec succès."
    else
      @dish_categories = DishCategory.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @dish_categories = DishCategory.ordered
  end

  def update
    apply_photo_only_defaults(@dish)
    if @dish.update(dish_params)
      redirect_to admin_dishes_path, notice: "Plat mis à jour."
    else
      @dish_categories = DishCategory.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dish.destroy
    redirect_to admin_dishes_path, notice: "Plat supprimé."
  end

  private

  def set_dish
    @dish = Dish.find(params[:id])
  end

  def dish_params
    params.require(:dish).permit(:position, :dish_category_id, :photo)
  end

  def apply_photo_only_defaults(dish)
    return if dish.persisted?

    dish.name = "Carte #{Time.current.to_i}" if dish.name.blank?
    dish.price = 0.01 if dish.price.blank?
  end
end
