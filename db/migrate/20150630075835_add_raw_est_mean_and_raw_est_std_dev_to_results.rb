class AddRawEstMeanAndRawEstStdDevToResults < ActiveRecord::Migration
  def change
    add_column :results, :raw_est_mean, :string
    add_column :results, :raw_est_std_dev, :string
  end
end
