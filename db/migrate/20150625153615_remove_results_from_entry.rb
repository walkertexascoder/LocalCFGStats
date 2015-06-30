class RemoveResultsFromEntry < ActiveRecord::Migration
  def change
    remove_column :entries, :results
  end
end
