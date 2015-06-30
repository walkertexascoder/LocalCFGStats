class AddEstStandoutToResults < ActiveRecord::Migration
  def change
    add_column :results, :est_standout, :float
    add_index :results, :est_standout
  end
end
