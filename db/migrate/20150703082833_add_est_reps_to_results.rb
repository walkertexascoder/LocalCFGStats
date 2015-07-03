class AddEstRepsToResults < ActiveRecord::Migration
  def change
    add_column :results, :est_reps, :jsonb
  end
end
