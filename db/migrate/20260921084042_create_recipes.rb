class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :title, null: false
      t.text :description
      t.integer :servings
      t.integer :prep_time_minutes
      t.integer :cook_time_minutes
      t.text :instructions

      t.timestamps
    end

    add_index :recipes, :title
  end
end
