class RenameEventsToEventAttrs < ActiveRecord::Migration
  def change
    rename_column :competitions, :events, :event_attrs
  end
end
