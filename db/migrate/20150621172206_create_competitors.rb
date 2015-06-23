class CreateCompetitors < ActiveRecord::Migration
  def change
    create_table :competitors do |t|
      t.integer :hq_id
      t.index :hq_id

      t.string :name
      t.string :name

      t.timestamps null: false
    end
  end
end
