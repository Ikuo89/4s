class CreateEvents < ActiveRecord::Migration[5.0]
  def up
    create_table :events, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.column :calendar_id, 'BIGINT', null: false
      t.string :google_event_id, null: false
      t.text :data, null: false
      t.datetime :start, null: false
      t.datetime :end, null: false

      t.column :deleted, 'BIGINT', null: false, default: 0
      t.timestamps null: false
    end
    add_foreign_key :events, :calendars, dependent: :delete
  end
  def down
    drop_table :events
  end
end
