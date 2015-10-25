class AddSpeedToTrackpoints < ActiveRecord::Migration
  def change
    add_column :trackpoints, :speed, :float
  end
end
