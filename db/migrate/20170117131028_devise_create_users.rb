class DeviseCreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users, id: false  do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.string :email,              null: false
      t.string :image, null: false
      t.text :encrypted_token, null: false
      t.text :encrypted_refresh_token, null: false
      t.string :salt, null: false

      t.column :deleted, 'BIGINT', null: false, default: 0


      t.timestamps null: false
    end

    add_index :users, [:email, :deleted],    unique: true
    add_index :users, [:salt], unique: true
  end
end
