class AddCompetitionIdToEntry < ActiveRecord::Migration
  def change
    change_table :entries do |t|
      t.integer :competition_id
      t.index :competition_id
    end
  end
end
