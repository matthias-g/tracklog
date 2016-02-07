class CreateTagsUsers < ActiveRecord::Migration
  def change
    create_table :tags_users do |t|
      t.integer :tag_id
      t.integer :user_id
    end
  end
end
