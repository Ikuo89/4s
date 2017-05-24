class CreateLineRoomTalks < ActiveRecord::Migration[5.0]
  def up
    create_table :line_room_talks, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.column :line_room_id, 'BIGINT', null: false
      t.string :text, null: false

      t.timestamps
    end
    add_foreign_key :line_room_talks, :line_rooms, on_delete: :cascade
  end
  def down
    drop_table :line_room_talks
  end
end
