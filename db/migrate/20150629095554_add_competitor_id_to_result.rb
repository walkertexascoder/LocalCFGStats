class AddCompetitorIdToResult < ActiveRecord::Migration
  def change
    add_column :results, :competitor_id, :integer
    add_index :results, :competitor_id
  end
end
