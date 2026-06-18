class CreateDishes < ActiveRecord::Migration[8.0]
  def change
    create_table :dishes do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 8, scale: 2, null: false
      t.integer :position, default: 0
      t.references :dish_category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :dishes, :position
  end
end
