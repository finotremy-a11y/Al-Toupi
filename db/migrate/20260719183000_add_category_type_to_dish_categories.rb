class AddCategoryTypeToDishCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :dish_categories, :category_type, :integer, default: 0, null: false
    add_index :dish_categories, :category_type
  end
end
