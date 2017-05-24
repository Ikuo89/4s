class CreateLineRoomCalendarRelations < ActiveRecord::Migration[5.0]
  def up
    create_table :line_room_calendar_relations, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.column :calendar_id, 'BIGINT', null: false
      t.column :line_room_id, 'BIGINT', null: false

      t.timestamps
    end
    add_foreign_key :line_room_calendar_relations, :calendars, on_delete: :cascade
    add_foreign_key :line_room_calendar_relations, :line_rooms, on_delete: :cascade
  end

  def down
    drop_table :line_room_calendar_relations
  end
end
