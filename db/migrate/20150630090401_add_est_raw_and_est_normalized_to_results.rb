class AddEstRawAndEstNormalizedToResults < ActiveRecord::Migration
  def change
    add_column :results, :est_raw, :string
    add_column :results, :est_normalized, :float
  end
end
