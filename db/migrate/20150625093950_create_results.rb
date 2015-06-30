class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :competition_id
      t.integer :entry_id
      t.integer :event_num
      t.string :raw
      t.float :normalized
      t.boolean :time_capped
      t.integer :rank
      t.float :mean
      t.float :std_dev
      t.float :est_mean
      t.float :est_std_dev
      t.float :standout

      t.timestamps null: false
    end
    add_index :results, :competition_id
    add_index :results, :entry_id
    add_index :results, :event_num
    add_index :results, :raw
    add_index :results, :rank
    add_index :results, :normalized
    add_index :results, :time_capped
    add_index :results, :mean
    add_index :results, :std_dev
    add_index :results, :est_mean
    add_index :results, :est_std_dev
    add_index :results, :standout
  end
end
