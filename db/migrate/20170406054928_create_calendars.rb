class CreateCalendars < ActiveRecord::Migration[5.0]
  def up
    create_table :calendars, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.string :google_calendar_id, null: false
      t.text :data, null: false

      t.column :deleted, 'BIGINT', null: false, default: 0
      t.timestamps null: false
    end
  end
  def down
    drop_table :calendars
  end
end
