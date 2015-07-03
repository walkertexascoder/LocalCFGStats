class AddRawEstMeanAndRawEstStdDevToResults < ActiveRecord::Migration
  def change
    add_column :results, :est_raw_mean, :string
    add_column :results, :est_raw_std_dev, :string
  end
end
