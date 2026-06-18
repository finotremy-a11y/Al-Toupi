class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos do |t|
      t.string :title
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :photos, :position
  end
end
