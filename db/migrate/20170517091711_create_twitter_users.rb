class CreateTwitterUsers < ActiveRecord::Migration[5.0]
  def up
    create_table :twitter_users, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.string :twitter_com_user_id, null: false
      t.text :data, null: false

      t.column :deleted, 'BIGINT', null: false, default: 0
      t.timestamps
    end
    add_index :twitter_users, [:twitter_com_user_id, :deleted], unique: true
  end

  def down
    drop_table :twitter_users
  end
end
