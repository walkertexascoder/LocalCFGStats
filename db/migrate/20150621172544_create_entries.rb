class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.integer :competitor_id
      t.index :competitor_id

      t.jsonb :tags
      t.index :tags, using: 'gin'

      t.jsonb :results
      t.index :results, using: 'gin'

      t.timestamps null: false
    end
  end
end
