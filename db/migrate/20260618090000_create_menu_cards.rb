class CreateMenuCards < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_cards do |t|
      t.string :title, null: false, default: "Carte du restaurant"

      t.timestamps
    end
  end
end
