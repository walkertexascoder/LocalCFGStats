class CreateCompetitions < ActiveRecord::Migration
  def change
    create_table :competitions do |t|
      t.jsonb :tags
      t.index :tags, using: 'gin'

      t.jsonb :events
      t.index :events, using: 'gin'

      t.timestamps null: false
    end
  end
end
