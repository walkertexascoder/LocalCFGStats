class AddRawStdDevAndRawMeanToResults < ActiveRecord::Migration
  def change
    add_column :results, :raw_std_dev, :string
    add_column :results, :raw_mean, :string
  end
end
