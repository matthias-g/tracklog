class RemoveSharedFromLog < ActiveRecord::Migration
  def change
    remove_column :logs, :shared, :boolean
  end
end
