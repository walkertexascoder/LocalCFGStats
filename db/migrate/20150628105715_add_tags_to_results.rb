class AddTagsToResults < ActiveRecord::Migration
  def change
    change_table :results do |t|
      t.jsonb :tags
      t.index :tags, using: 'gin'
    end
  end
end
