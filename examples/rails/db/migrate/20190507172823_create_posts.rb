class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.text :body
      t.timestamps
      t.index :slug, unique: true
    end
  end
end
