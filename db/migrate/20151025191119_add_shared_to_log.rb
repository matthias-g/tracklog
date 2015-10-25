class AddSharedToLog < ActiveRecord::Migration
  def change
    add_column :logs, :shared, :boolean
  end
end
