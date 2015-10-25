class AddIsRestrictedToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_restricted, :boolean
  end
end
