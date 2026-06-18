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
    params.require(:dish).permit(:name, :description, :price, :position, :dish_category_id, :photo)
  end
end
