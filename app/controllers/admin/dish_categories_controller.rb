class Admin::DishCategoriesController < Admin::BaseController
  before_action :set_dish_category, only: %i[edit update destroy]

  def index
    @dish_categories = DishCategory.ordered
  end

  def new
    @dish_category = DishCategory.new
  end

  def create
    @dish_category = DishCategory.new(dish_category_params)
    if @dish_category.save
      redirect_to admin_dish_categories_path, notice: "Catégorie créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @dish_category.update(dish_category_params)
      redirect_to admin_dish_categories_path, notice: "Catégorie mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dish_category.destroy
    redirect_to admin_dish_categories_path, notice: "Catégorie supprimée."
  end

  private

  def set_dish_category
    @dish_category = DishCategory.find(params[:id])
  end

  def dish_category_params
    params.require(:dish_category).permit(:name, :position)
  end
end
