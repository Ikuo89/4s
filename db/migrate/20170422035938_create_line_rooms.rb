class CreateLineRooms < ActiveRecord::Migration[5.0]
  def up
    create_table :line_rooms, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.string :line_me_room_id, null: false

      t.timestamps
    end
    add_index :line_rooms, [:line_me_room_id], unique: true
  end
  def down
    drop_table :line_rooms
  end
end
