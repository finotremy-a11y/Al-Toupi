class CreateDishCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :dish_categories do |t|
      t.string :name, null: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :dish_categories, :position
  end
end
